puts "Seeding Minecraft servers..."

MinecraftServer.find_or_create_by!(container_name: "mc-survival") do |s|
  s.server_name = "Survival World"
  s.gamemode = "survival"
  s.difficulty = "normal"
  s.max_players = 20
  s.server_port = 19132
  s.server_port_v6 = 19133
  s.level_name = "SurvivalWorld"
  s.view_distance = 32
end

MinecraftServer.find_or_create_by!(container_name: "mc-creative") do |s|
  s.server_name = "Creative Playground"
  s.gamemode = "creative"
  s.difficulty = "peaceful"
  s.allow_cheats = true
  s.max_players = 10
  s.server_port = 19134
  s.server_port_v6 = 19135
  s.level_name = "CreativeWorld"
  s.level_type = "FLAT"
  s.view_distance = 24
end

puts "Done! Created #{MinecraftServer.count} servers."
