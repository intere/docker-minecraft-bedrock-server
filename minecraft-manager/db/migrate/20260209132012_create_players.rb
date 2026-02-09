class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.string :gamertag, null: false
      t.string :xuid, null: false

      t.timestamps
    end

    add_index :players, :gamertag, unique: true
    add_index :players, :xuid, unique: true
  end
end
