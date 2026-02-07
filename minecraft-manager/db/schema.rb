# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_07_000001) do
  create_table "minecraft_servers", force: :cascade do |t|
    t.boolean "allow_cheats", default: false
    t.boolean "allow_inbound_script_debugging", default: false
    t.boolean "allow_list", default: false
    t.string "allow_list_users", default: ""
    t.boolean "allow_outbound_script_debugging", default: false
    t.boolean "block_network_ids_are_hashes", default: true
    t.string "chat_restriction", default: "None"
    t.boolean "client_side_chunk_generation_enabled", default: true
    t.string "compression_algorithm", default: "zlib"
    t.integer "compression_threshold", default: 1
    t.string "container_id"
    t.string "container_name", null: false
    t.boolean "content_log_console_output_enabled", default: false
    t.boolean "content_log_file_enabled", default: false
    t.string "content_log_level", default: "info"
    t.boolean "correct_player_movement", default: false
    t.datetime "created_at", null: false
    t.string "default_player_permission_level", default: "member"
    t.string "difficulty", default: "easy"
    t.boolean "disable_custom_skins", default: false
    t.boolean "disable_persona", default: false
    t.boolean "disable_player_interaction", default: false
    t.boolean "emit_server_telemetry", default: false
    t.boolean "enable_lan_visibility", default: true
    t.boolean "enable_ssh", default: false
    t.boolean "force_gamemode", default: false
    t.integer "force_inbound_debug_port", default: 19144
    t.string "gamemode", default: "survival"
    t.boolean "item_transaction_logging_enabled", default: false
    t.string "level_name", default: "Bedrock level"
    t.string "level_seed", default: ""
    t.string "level_type", default: "DEFAULT"
    t.integer "max_players", default: 10
    t.integer "max_threads", default: 8
    t.string "members", default: ""
    t.boolean "msa_gamertags_only", default: false
    t.boolean "online_mode", default: true
    t.integer "op_permission_level", default: 4
    t.string "ops", default: ""
    t.integer "player_idle_timeout", default: 30
    t.float "player_movement_action_direction_threshold", default: 0.85
    t.float "player_movement_distance_threshold", default: 0.3
    t.integer "player_movement_duration_threshold_in_ms", default: 500
    t.integer "player_movement_score_threshold", default: 20
    t.float "player_position_acceptance_threshold", default: 0.5
    t.string "script_debugger_auto_attach", default: "disabled"
    t.string "script_debugger_auto_attach_connect_address", default: "localhost:19144"
    t.boolean "script_watchdog_enable", default: true
    t.boolean "script_watchdog_enable_exception_handling", default: true
    t.boolean "script_watchdog_enable_shutdown", default: true
    t.boolean "script_watchdog_hang_exception", default: true
    t.integer "script_watchdog_hang_threshold", default: 10000
    t.integer "script_watchdog_memory_limit", default: 250
    t.integer "script_watchdog_memory_warning", default: 100
    t.integer "script_watchdog_slow_threshold", default: 10
    t.integer "script_watchdog_spike_threshold", default: 100
    t.boolean "server_authoritative_block_breaking", default: false
    t.float "server_authoritative_block_breaking_pick_range_scalar", default: 1.5
    t.string "server_authoritative_movement", default: "server-auth"
    t.string "server_build_radius_ratio", default: "Disabled"
    t.string "server_name", default: "Dedicated Server"
    t.integer "server_port", null: false
    t.integer "server_port_v6", null: false
    t.string "status", default: "stopped"
    t.boolean "texturepack_required", default: false
    t.integer "tick_distance", default: 4
    t.datetime "updated_at", null: false
    t.string "version", default: "LATEST"
    t.integer "view_distance", default: 32
    t.string "visitors", default: ""
    t.index ["container_name"], name: "index_minecraft_servers_on_container_name", unique: true
    t.index ["server_port"], name: "index_minecraft_servers_on_server_port", unique: true
    t.index ["server_port_v6"], name: "index_minecraft_servers_on_server_port_v6", unique: true
  end
end
