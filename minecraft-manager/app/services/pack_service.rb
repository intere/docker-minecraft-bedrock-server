class PackService
  class PackError < StandardError; end

  def self.library_dir
    File.expand_path("pack-library", Rails.root)
  end

  def self.import(uploaded_file)
    new.import(uploaded_file)
  end

  def self.assign(server, pack)
    new.assign(server, pack)
  end

  def self.unassign(server, pack)
    new.unassign(server, pack)
  end

  def self.delete_pack(pack)
    new.delete_pack(pack)
  end

  def import(uploaded_file)
    zip_path = uploaded_file.tempfile.path

    # Read manifest directly from the zip without extracting
    manifest, manifest_prefix = read_manifest_from_zip(zip_path)
    pack_type = detect_pack_type(manifest)
    pack_name = manifest.dig("header", "name") || "unknown"
    pack_uuid = manifest.dig("header", "uuid")
    pack_version = manifest.dig("header", "version")

    raise PackError, "Missing UUID in manifest" unless pack_uuid
    raise PackError, "Missing version in manifest" unless pack_version

    version_string = pack_version.is_a?(Array) ? pack_version.join(".") : pack_version.to_s

    # Extract directly to library directory
    library_dir = self.class.library_dir
    pack_folder = sanitize_folder_name(pack_name)
    dest_path = File.join(library_dir, pack_folder)
    FileUtils.rm_rf(dest_path) if Dir.exist?(dest_path)
    FileUtils.mkdir_p(dest_path)

    extract_zip_to(zip_path, dest_path, manifest_prefix)

    # Create or update the database record
    pack = Pack.find_or_initialize_by(uuid: pack_uuid)
    pack.assign_attributes(
      name: pack_name,
      version: version_string,
      pack_type: pack_type,
      file_path: dest_path
    )
    pack.save!

    { success: true, message: "Imported #{pack_type} pack '#{pack_name}' v#{version_string}", pack: pack }
  rescue Zip::Error => e
    { success: false, message: "Invalid ZIP file: #{e.message}" }
  rescue PackError => e
    { success: false, message: e.message }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, message: "Failed to save pack: #{e.message}" }
  rescue => e
    { success: false, message: "Failed to import pack: #{e.message}" }
  end

  def assign(server, pack)
    server_pack = ServerPack.find_or_create_by!(minecraft_server: server, pack: pack)

    # Copy pack files to server's data volume
    dest_base = pack.pack_type == "behavior" ? behavior_packs_dir(server) : resource_packs_dir(server)
    pack_folder = File.basename(pack.file_path)
    dest_path = File.join(dest_base, pack_folder)

    FileUtils.rm_rf(dest_path) if Dir.exist?(dest_path)
    FileUtils.mkdir_p(dest_base)
    FileUtils.cp_r(pack.file_path, dest_path)

    # Register in world config
    register_pack(server, pack)

    { success: true, message: "Added '#{pack.name}' to #{server.server_name}" }
  rescue => e
    { success: false, message: "Failed to assign pack: #{e.message}" }
  end

  def unassign(server, pack)
    server_pack = ServerPack.find_by(minecraft_server: server, pack: pack)
    return { success: false, message: "Pack not assigned to this server" } unless server_pack

    # Remove pack files from server's data volume
    dest_base = pack.pack_type == "behavior" ? behavior_packs_dir(server) : resource_packs_dir(server)
    pack_folder = File.basename(pack.file_path)
    dest_path = File.join(dest_base, pack_folder)
    FileUtils.rm_rf(dest_path) if Dir.exist?(dest_path)

    # Unregister from world config
    unregister_pack(server, pack)

    server_pack.destroy
    { success: true, message: "Removed '#{pack.name}' from #{server.server_name}" }
  rescue => e
    { success: false, message: "Failed to remove pack: #{e.message}" }
  end

  def delete_pack(pack)
    # Unassign from all servers first
    pack.server_packs.includes(:minecraft_server).each do |sp|
      unassign(sp.minecraft_server, pack)
    end

    # Remove from library
    FileUtils.rm_rf(pack.file_path) if pack.file_path.present? && Dir.exist?(pack.file_path)

    pack.destroy
    { success: true, message: "Deleted pack '#{pack.name}'" }
  rescue => e
    { success: false, message: "Failed to delete pack: #{e.message}" }
  end

  private

  def behavior_packs_dir(server)
    File.join(server.data_volume_path, "behavior_packs")
  end

  def resource_packs_dir(server)
    File.join(server.data_volume_path, "resource_packs")
  end

  def world_dir(server)
    File.join(server.data_volume_path, "worlds", server.level_name)
  end

  def read_manifest_from_zip(zip_path)
    Zip::File.open(zip_path) do |zip|
      manifest_entry = zip.entries.find { |e| e.name.end_with?("manifest.json") }
      raise PackError, "No manifest.json found in pack" unless manifest_entry

      manifest = JSON.parse(manifest_entry.get_input_stream.read)

      # Determine the prefix to strip (directory containing manifest.json)
      prefix = File.dirname(manifest_entry.name)
      prefix = "" if prefix == "."

      [manifest, prefix]
    end
  rescue JSON::ParserError
    raise PackError, "Invalid manifest.json"
  end

  def extract_zip_to(zip_path, dest_path, prefix)
    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        # Strip the prefix so files go directly into dest_path
        relative_name = if prefix.present? && entry.name.start_with?(prefix)
          entry.name.sub("#{prefix}/", "")
        else
          entry.name
        end
        next if relative_name.blank?

        target = File.join(dest_path, relative_name)
        raise PackError, "Invalid zip entry path" if target.include?("..")

        if entry.directory?
          FileUtils.mkdir_p(target)
        else
          FileUtils.mkdir_p(File.dirname(target))
          # Write file contents directly instead of using entry.extract
          File.binwrite(target, entry.get_input_stream.read)
        end
      end
    end
  end

  def detect_pack_type(manifest)
    modules = manifest["modules"] || []
    types = modules.map { |m| m["type"] }

    if types.include?("data") || types.include?("script")
      "behavior"
    elsif types.include?("resources")
      "resource"
    else
      "behavior"
    end
  end

  def sanitize_folder_name(name)
    name.gsub(/[^a-zA-Z0-9_\-. ]/, "").strip.gsub(/\s+/, "_")
  end

  def register_pack(server, pack)
    config_file = pack.pack_type == "behavior" ? "world_behavior_packs.json" : "world_resource_packs.json"
    config_path = File.join(world_dir(server), config_file)

    FileUtils.mkdir_p(world_dir(server))

    packs = File.exist?(config_path) ? JSON.parse(File.read(config_path)) : []
    packs.reject! { |p| p["pack_id"] == pack.uuid }
    version_array = pack.version.split(".").map(&:to_i)
    packs << { "pack_id" => pack.uuid, "version" => version_array }

    File.write(config_path, JSON.pretty_generate(packs))
  end

  def unregister_pack(server, pack)
    config_file = pack.pack_type == "behavior" ? "world_behavior_packs.json" : "world_resource_packs.json"
    config_path = File.join(world_dir(server), config_file)

    return unless File.exist?(config_path)

    packs = JSON.parse(File.read(config_path))
    packs.reject! { |p| p["pack_id"] == pack.uuid }
    File.write(config_path, JSON.pretty_generate(packs))
  rescue JSON::ParserError
    # corrupted config, nothing to clean up
  end
end
