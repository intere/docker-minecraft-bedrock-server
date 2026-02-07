class CreateMinecraftServers < ActiveRecord::Migration[8.1]
  def change
    create_table :minecraft_servers do |t|
      # Docker management
      t.string :container_name, null: false
      t.string :container_id
      t.string :status, default: "stopped"

      # Core server settings
      t.string :server_name, default: "Dedicated Server"
      t.string :gamemode, default: "survival"
      t.boolean :force_gamemode, default: false
      t.string :difficulty, default: "easy"
      t.boolean :allow_cheats, default: false
      t.integer :max_players, default: 10
      t.boolean :online_mode, default: true
      t.string :default_player_permission_level, default: "member"
      t.integer :player_idle_timeout, default: 30
      t.integer :op_permission_level, default: 4

      # Network settings
      t.integer :server_port, null: false
      t.integer :server_port_v6, null: false
      t.boolean :enable_lan_visibility, default: true

      # World settings
      t.string :level_name, default: "Bedrock level"
      t.string :level_seed, default: ""
      t.string :level_type, default: "DEFAULT"

      # Performance settings
      t.integer :view_distance, default: 32
      t.integer :tick_distance, default: 4
      t.integer :max_threads, default: 8
      t.integer :compression_threshold, default: 1
      t.string :compression_algorithm, default: "zlib"
      t.boolean :client_side_chunk_generation_enabled, default: true
      t.string :server_build_radius_ratio, default: "Disabled"

      # Access control
      t.boolean :allow_list, default: false
      t.boolean :texturepack_required, default: false
      t.string :allow_list_users, default: ""
      t.string :ops, default: ""
      t.string :members, default: ""
      t.string :visitors, default: ""

      # Anti-cheat / movement authority
      t.string :server_authoritative_movement, default: "server-auth"
      t.float :player_position_acceptance_threshold, default: 0.5
      t.integer :player_movement_score_threshold, default: 20
      t.float :player_movement_action_direction_threshold, default: 0.85
      t.float :player_movement_distance_threshold, default: 0.3
      t.integer :player_movement_duration_threshold_in_ms, default: 500
      t.boolean :correct_player_movement, default: false
      t.boolean :server_authoritative_block_breaking, default: false
      t.float :server_authoritative_block_breaking_pick_range_scalar, default: 1.5

      # Chat & interaction
      t.string :chat_restriction, default: "None"
      t.boolean :disable_player_interaction, default: false

      # Appearance
      t.boolean :disable_persona, default: false
      t.boolean :disable_custom_skins, default: false
      t.boolean :block_network_ids_are_hashes, default: true

      # Logging
      t.boolean :content_log_file_enabled, default: false
      t.string :content_log_level, default: "info"
      t.boolean :content_log_console_output_enabled, default: false

      # Telemetry
      t.boolean :emit_server_telemetry, default: false
      t.boolean :msa_gamertags_only, default: false
      t.boolean :item_transaction_logging_enabled, default: false

      # Script debugging
      t.boolean :allow_outbound_script_debugging, default: false
      t.boolean :allow_inbound_script_debugging, default: false
      t.integer :force_inbound_debug_port, default: 19144
      t.string :script_debugger_auto_attach, default: "disabled"
      t.string :script_debugger_auto_attach_connect_address, default: "localhost:19144"

      # Script watchdog
      t.boolean :script_watchdog_enable, default: true
      t.boolean :script_watchdog_enable_exception_handling, default: true
      t.boolean :script_watchdog_enable_shutdown, default: true
      t.boolean :script_watchdog_hang_exception, default: true
      t.integer :script_watchdog_hang_threshold, default: 10000
      t.integer :script_watchdog_spike_threshold, default: 100
      t.integer :script_watchdog_slow_threshold, default: 10
      t.integer :script_watchdog_memory_warning, default: 100
      t.integer :script_watchdog_memory_limit, default: 250

      # Container settings
      t.string :version, default: "LATEST"
      t.boolean :enable_ssh, default: false

      t.timestamps
    end

    add_index :minecraft_servers, :container_name, unique: true
    add_index :minecraft_servers, :server_port, unique: true
    add_index :minecraft_servers, :server_port_v6, unique: true
  end
end
