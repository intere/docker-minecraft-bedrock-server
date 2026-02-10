class ServerPack < ApplicationRecord
  belongs_to :minecraft_server
  belongs_to :pack

  validates :pack_id, uniqueness: { scope: :minecraft_server_id, message: "is already assigned to this server" }
end
