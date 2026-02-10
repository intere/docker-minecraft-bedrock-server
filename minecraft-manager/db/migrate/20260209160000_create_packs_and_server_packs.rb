class CreatePacksAndServerPacks < ActiveRecord::Migration[8.1]
  def change
    create_table :packs do |t|
      t.string :name, null: false
      t.string :uuid, null: false
      t.string :version, null: false
      t.string :pack_type, null: false
      t.string :file_path, null: false
      t.timestamps
    end

    add_index :packs, :uuid, unique: true

    create_table :server_packs do |t|
      t.references :minecraft_server, null: false, foreign_key: true
      t.references :pack, null: false, foreign_key: true
      t.timestamps
    end

    add_index :server_packs, [:minecraft_server_id, :pack_id], unique: true
  end
end
