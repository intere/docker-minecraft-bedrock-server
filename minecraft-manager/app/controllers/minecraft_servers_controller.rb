class MinecraftServersController < ApplicationController
  before_action :set_server, only: %i[show edit update destroy start stop restart logs]

  def index
    DockerService.sync_all_statuses
    @servers = MinecraftServer.order(:server_name)
  end

  def show
  end

  def new
    @server = MinecraftServer.new
  end

  def create
    @server = MinecraftServer.new(server_params)
    if @server.save
      redirect_to @server, notice: "Minecraft server '#{@server.server_name}' was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @server.update(server_params)
      redirect_to @server, notice: "Server configuration updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    DockerService.stop_server(@server) if @server.running?
    @server.destroy
    redirect_to minecraft_servers_path, notice: "Server '#{@server.server_name}' was deleted."
  end

  def start
    result = DockerService.start_server(@server)
    if result[:success]
      redirect_to @server, notice: result[:message]
    else
      redirect_to @server, alert: result[:message]
    end
  end

  def stop
    result = DockerService.stop_server(@server)
    if result[:success]
      redirect_to @server, notice: result[:message]
    else
      redirect_to @server, alert: result[:message]
    end
  end

  def restart
    result = DockerService.restart_server(@server)
    if result[:success]
      redirect_to @server, notice: result[:message]
    else
      redirect_to @server, alert: result[:message]
    end
  end

  def logs
    @logs = DockerService.server_logs(@server, lines: 200)
    render :logs
  end

  private

  def set_server
    @server = MinecraftServer.find(params[:id])
  end

  def server_params
    params.require(:minecraft_server).permit(
      :container_name, :server_name, :gamemode, :force_gamemode, :difficulty,
      :allow_cheats, :max_players, :online_mode, :default_player_permission_level,
      :player_idle_timeout, :op_permission_level,
      :server_port, :server_port_v6, :enable_lan_visibility,
      :level_name, :level_seed, :level_type,
      :view_distance, :tick_distance, :max_threads, :compression_threshold,
      :compression_algorithm, :client_side_chunk_generation_enabled,
      :server_build_radius_ratio,
      :allow_list, :texturepack_required, :allow_list_users,
      :ops, :members, :visitors,
      :server_authoritative_movement, :player_position_acceptance_threshold,
      :player_movement_score_threshold, :player_movement_action_direction_threshold,
      :player_movement_distance_threshold, :player_movement_duration_threshold_in_ms,
      :correct_player_movement, :server_authoritative_block_breaking,
      :server_authoritative_block_breaking_pick_range_scalar,
      :chat_restriction, :disable_player_interaction,
      :disable_persona, :disable_custom_skins, :block_network_ids_are_hashes,
      :content_log_file_enabled, :content_log_level, :content_log_console_output_enabled,
      :emit_server_telemetry, :msa_gamertags_only, :item_transaction_logging_enabled,
      :allow_outbound_script_debugging, :allow_inbound_script_debugging,
      :force_inbound_debug_port, :script_debugger_auto_attach,
      :script_debugger_auto_attach_connect_address,
      :script_watchdog_enable, :script_watchdog_enable_exception_handling,
      :script_watchdog_enable_shutdown, :script_watchdog_hang_exception,
      :script_watchdog_hang_threshold, :script_watchdog_spike_threshold,
      :script_watchdog_slow_threshold, :script_watchdog_memory_warning,
      :script_watchdog_memory_limit,
      :version, :enable_ssh
    )
  end
end
