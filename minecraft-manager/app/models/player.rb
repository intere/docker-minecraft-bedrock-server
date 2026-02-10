class Player < ApplicationRecord
  default_scope { order(:gamertag) }

  validates :gamertag, presence: true, uniqueness: true
  validates :xuid, presence: true, uniqueness: true

  def to_allow_list_entry
    "#{gamertag}:#{xuid}"
  end
end
