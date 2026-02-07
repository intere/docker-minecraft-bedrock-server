class MinecraftServer < ApplicationRecord
  # -- Enumerations --
  GAMEMODES = %w[survival creative adventure].freeze
  DIFFICULTIES = %w[peaceful easy normal hard].freeze
  LEVEL_TYPES = %w[DEFAULT FLAT LEGACY].freeze
  PERMISSION_LEVELS = %w[visitor member operator].freeze
  COMPRESSION_ALGORITHMS = %w[zlib snappy].freeze
  MOVEMENT_AUTHORITIES = %w[server-auth client-auth server-auth-with-rewind].freeze
  CHAT_RESTRICTIONS = %w[None Dropped Disabled].freeze
  CONTENT_LOG_LEVELS = %w[verbose info warning error].freeze
  DEBUGGER_AUTO_ATTACH_MODES = %w[disabled connect listen].freeze
  VERSIONS = %w[LATEST PREVIEW].freeze

  # -- Validations --
  validates :container_name, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9_.-]*\z/, message: "must start with alphanumeric and contain only letters, digits, underscores, dots, or hyphens" }
  validates :server_name, presence: true

  # Network
  validates :server_port, presence: true, uniqueness: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1024, less_than_or_equal_to: 65535 }
  validates :server_port_v6, presence: true, uniqueness: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1024, less_than_or_equal_to: 65535 }

  # Enums
  validates :gamemode, inclusion: { in: GAMEMODES }
  validates :difficulty, inclusion: { in: DIFFICULTIES }
  validates :level_type, inclusion: { in: LEVEL_TYPES }
  validates :default_player_permission_level, inclusion: { in: PERMISSION_LEVELS }
  validates :compression_algorithm, inclusion: { in: COMPRESSION_ALGORITHMS }
  validates :server_authoritative_movement, inclusion: { in: MOVEMENT_AUTHORITIES }
  validates :chat_restriction, inclusion: { in: CHAT_RESTRICTIONS }
  validates :content_log_level, inclusion: { in: CONTENT_LOG_LEVELS }
  validates :script_debugger_auto_attach, inclusion: { in: DEBUGGER_AUTO_ATTACH_MODES }

  # Integers with ranges
  validates :max_players, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :player_idle_timeout, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :op_permission_level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }
  validates :view_distance, numericality: { only_integer: true, greater_than_or_equal_to: 5, less_than_or_equal_to: 96 }
  validates :tick_distance, numericality: { only_integer: true, greater_than_or_equal_to: 4, less_than_or_equal_to: 12 }
  validates :max_threads, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :compression_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 65535 }

  # Floats with ranges
  validates :player_position_acceptance_threshold, numericality: { greater_than_or_equal_to: 0.0 }
  validates :player_movement_action_direction_threshold, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }

  # Script watchdog ranges
  validates :script_watchdog_hang_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 3000, less_than_or_equal_to: 20000 }
  validates :script_watchdog_spike_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 50, less_than_or_equal_to: 500 }
  validates :script_watchdog_slow_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 5, less_than_or_equal_to: 50 }
  validates :script_watchdog_memory_warning, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2000 }
  validates :script_watchdog_memory_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2000 }

  # Debug port
  validates :force_inbound_debug_port, numericality: { only_integer: true, greater_than_or_equal_to: 1024, less_than_or_equal_to: 65535 }

  # Server build radius ratio: "Disabled" or float 0.0-1.0
  validate :validate_server_build_radius_ratio

  # -- Callbacks --
  before_validation :assign_ports, on: :create

  # -- Class methods --
  def self.next_available_port
    max_port = maximum(:server_port) || 19130
    max_port + 2
  end

  def self.next_available_port_v6
    max_port = maximum(:server_port_v6) || 19131
    max_port + 2
  end

  # -- Instance methods --
  def running?
    status == "running"
  end

  def stopped?
    status == "stopped"
  end

  def data_volume_path
    Rails.root.join("server-data", container_name).to_s
  end

  def environment_variables
    {
      "EULA" => "TRUE",
      "VERSION" => version,
      "SERVER_NAME" => server_name,
      "GAMEMODE" => gamemode,
      "FORCE_GAMEMODE" => force_gamemode.to_s,
      "DIFFICULTY" => difficulty,
      "ALLOW_CHEATS" => allow_cheats.to_s,
      "MAX_PLAYERS" => max_players.to_s,
      "ONLINE_MODE" => online_mode.to_s,
      "DEFAULT_PLAYER_PERMISSION_LEVEL" => default_player_permission_level,
      "PLAYER_IDLE_TIMEOUT" => player_idle_timeout.to_s,
      "OP_PERMISSION_LEVEL" => op_permission_level.to_s,
      "SERVER_PORT" => server_port.to_s,
      "SERVER_PORT_V6" => server_port_v6.to_s,
      "ENABLE_LAN_VISIBILITY" => enable_lan_visibility.to_s,
      "LEVEL_NAME" => level_name,
      "LEVEL_SEED" => level_seed.to_s,
      "LEVEL_TYPE" => level_type,
      "VIEW_DISTANCE" => view_distance.to_s,
      "TICK_DISTANCE" => tick_distance.to_s,
      "MAX_THREADS" => max_threads.to_s,
      "COMPRESSION_THRESHOLD" => compression_threshold.to_s,
      "COMPRESSION_ALGORITHM" => compression_algorithm,
      "CLIENT_SIDE_CHUNK_GENERATION_ENABLED" => client_side_chunk_generation_enabled.to_s,
      "SERVER_BUILD_RADIUS_RATIO" => server_build_radius_ratio,
      "ALLOW_LIST" => allow_list.to_s,
      "TEXTUREPACK_REQUIRED" => texturepack_required.to_s,
      "SERVER_AUTHORITATIVE_MOVEMENT" => server_authoritative_movement,
      "PLAYER_POSITION_ACCEPTANCE_THRESHOLD" => player_position_acceptance_threshold.to_s,
      "PLAYER_MOVEMENT_SCORE_THRESHOLD" => player_movement_score_threshold.to_s,
      "PLAYER_MOVEMENT_ACTION_DIRECTION_THRESHOLD" => player_movement_action_direction_threshold.to_s,
      "PLAYER_MOVEMENT_DISTANCE_THRESHOLD" => player_movement_distance_threshold.to_s,
      "PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS" => player_movement_duration_threshold_in_ms.to_s,
      "CORRECT_PLAYER_MOVEMENT" => correct_player_movement.to_s,
      "SERVER_AUTHORITATIVE_BLOCK_BREAKING" => server_authoritative_block_breaking.to_s,
      "SERVER_AUTHORITATIVE_BLOCK_BREAKING_PICK_RANGE_SCALAR" => server_authoritative_block_breaking_pick_range_scalar.to_s,
      "CHAT_RESTRICTION" => chat_restriction,
      "DISABLE_PLAYER_INTERACTION" => disable_player_interaction.to_s,
      "DISABLE_PERSONA" => disable_persona.to_s,
      "DISABLE_CUSTOM_SKINS" => disable_custom_skins.to_s,
      "BLOCK_NETWORK_IDS_ARE_HASHES" => block_network_ids_are_hashes.to_s,
      "CONTENT_LOG_FILE_ENABLED" => content_log_file_enabled.to_s,
      "CONTENT_LOG_LEVEL" => content_log_level,
      "CONTENT_LOG_CONSOLE_OUTPUT_ENABLED" => content_log_console_output_enabled.to_s,
      "EMIT_SERVER_TELEMETRY" => emit_server_telemetry.to_s,
      "MSA_GAMERTAGS_ONLY" => msa_gamertags_only.to_s,
      "ITEM_TRANSACTION_LOGGING_ENABLED" => item_transaction_logging_enabled.to_s,
      "ALLOW_OUTBOUND_SCRIPT_DEBUGGING" => allow_outbound_script_debugging.to_s,
      "ALLOW_INBOUND_SCRIPT_DEBUGGING" => allow_inbound_script_debugging.to_s,
      "FORCE_INBOUND_DEBUG_PORT" => force_inbound_debug_port.to_s,
      "SCRIPT_DEBUGGER_AUTO_ATTACH" => script_debugger_auto_attach,
      "SCRIPT_DEBUGGER_AUTO_ATTACH_CONNECT_ADDRESS" => script_debugger_auto_attach_connect_address,
      "SCRIPT_WATCHDOG_ENABLE" => script_watchdog_enable.to_s,
      "SCRIPT_WATCHDOG_ENABLE_EXCEPTION_HANDLING" => script_watchdog_enable_exception_handling.to_s,
      "SCRIPT_WATCHDOG_ENABLE_SHUTDOWN" => script_watchdog_enable_shutdown.to_s,
      "SCRIPT_WATCHDOG_HANG_EXCEPTION" => script_watchdog_hang_exception.to_s,
      "SCRIPT_WATCHDOG_HANG_THRESHOLD" => script_watchdog_hang_threshold.to_s,
      "SCRIPT_WATCHDOG_SPIKE_THRESHOLD" => script_watchdog_spike_threshold.to_s,
      "SCRIPT_WATCHDOG_SLOW_THRESHOLD" => script_watchdog_slow_threshold.to_s,
      "SCRIPT_WATCHDOG_MEMORY_WARNING" => script_watchdog_memory_warning.to_s,
      "SCRIPT_WATCHDOG_MEMORY_LIMIT" => script_watchdog_memory_limit.to_s,
      "ENABLE_SSH" => enable_ssh.to_s
    }.tap do |env|
      env["OPS"] = ops if ops.present?
      env["MEMBERS"] = members if members.present?
      env["VISITORS"] = visitors if visitors.present?
      env["ALLOW_LIST_USERS"] = allow_list_users if allow_list_users.present?
    end
  end

  def docker_compose_hash
    {
      "services" => {
        container_name => {
          "image" => "itzg/minecraft-bedrock-server",
          "container_name" => container_name,
          "environment" => environment_variables,
          "ports" => [
            "#{server_port}:19132/udp",
            "#{server_port_v6}:19133/udp"
          ],
          "volumes" => [
            "#{data_volume_path}:/data"
          ],
          "stdin_open" => true,
          "tty" => true,
          "restart" => "unless-stopped"
        }
      }
    }
  end

  private

  def assign_ports
    self.server_port ||= self.class.next_available_port
    self.server_port_v6 ||= self.class.next_available_port_v6
  end

  def validate_server_build_radius_ratio
    return if server_build_radius_ratio == "Disabled"

    ratio = Float(server_build_radius_ratio, exception: false)
    if ratio.nil? || ratio < 0.0 || ratio > 1.0
      errors.add(:server_build_radius_ratio, "must be 'Disabled' or a number between 0.0 and 1.0")
    end
  end
end
