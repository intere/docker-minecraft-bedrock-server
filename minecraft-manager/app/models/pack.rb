class Pack < ApplicationRecord
  PACK_TYPES = %w[behavior resource].freeze

  has_many :server_packs, dependent: :destroy
  has_many :minecraft_servers, through: :server_packs

  validates :name, presence: true
  validates :uuid, presence: true, uniqueness: true
  validates :version, presence: true
  validates :pack_type, presence: true, inclusion: { in: PACK_TYPES }
  validates :file_path, presence: true

  scope :behavior, -> { where(pack_type: "behavior") }
  scope :resource, -> { where(pack_type: "resource") }

  default_scope { order(:name) }

  def version_display
    version
  end

  def type_label
    pack_type.capitalize
  end
end
