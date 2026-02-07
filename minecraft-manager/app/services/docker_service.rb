require "open3"
require "json"
require "yaml"
require "fileutils"

class DockerService
  class DockerError < StandardError; end

  def self.start_server(server)
    new(server).start
  end

  def self.stop_server(server)
    new(server).stop
  end

  def self.restart_server(server)
    new(server).restart
  end

  def self.server_status(server)
    new(server).status
  end

  def self.server_logs(server, lines: 100)
    new(server).logs(lines: lines)
  end

  def self.sync_all_statuses
    running_containers = list_running_containers
    MinecraftServer.find_each do |server|
      new_status = running_containers.include?(server.container_name) ? "running" : "stopped"
      server.update_column(:status, new_status) if server.status != new_status
    end
  end

  def self.list_running_containers
    output, status = Open3.capture2("docker", "ps", "--format", "{{.Names}}")
    return [] unless status.success?
    output.strip.split("\n")
  end

  def initialize(server)
    @server = server
  end

  def start
    ensure_data_directory
    write_compose_file

    output, err, status = run_compose("up", "-d")
    if status.success?
      update_container_id
      @server.update!(status: "running")
      { success: true, message: "Server started successfully" }
    else
      { success: false, message: "Failed to start server: #{err}" }
    end
  end

  def stop
    output, err, status = run_compose("down")
    if status.success?
      @server.update!(status: "stopped", container_id: nil)
      { success: true, message: "Server stopped successfully" }
    else
      { success: false, message: "Failed to stop server: #{err}" }
    end
  end

  def restart
    stop_result = stop
    return stop_result unless stop_result[:success]
    start
  end

  def status
    output, status = Open3.capture2(
      "docker", "inspect", "--format", "{{.State.Status}}", @server.container_name
    )
    if status.success?
      output.strip
    else
      "stopped"
    end
  end

  def logs(lines: 100)
    output, _status = Open3.capture2(
      "docker", "logs", "--tail", lines.to_s, @server.container_name
    )
    output
  rescue => e
    "Error fetching logs: #{e.message}"
  end

  private

  def compose_dir
    Rails.root.join("server-compose", @server.container_name).to_s
  end

  def compose_file
    File.join(compose_dir, "docker-compose.yml")
  end

  def ensure_data_directory
    FileUtils.mkdir_p(@server.data_volume_path)
  end

  def write_compose_file
    FileUtils.mkdir_p(compose_dir)
    File.write(compose_file, @server.docker_compose_hash.to_yaml)
  end

  def run_compose(*args)
    Open3.capture3("docker", "compose", "-f", compose_file, *args)
  end

  def update_container_id
    output, status = Open3.capture2(
      "docker", "inspect", "--format", "{{.Id}}", @server.container_name
    )
    @server.update_column(:container_id, output.strip) if status.success?
  end
end
