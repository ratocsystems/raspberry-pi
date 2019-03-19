class CreateMachines < ActiveRecord::Migration[5.2]
  def change
    create_table :machines do |t|
      t.macaddr :mac

      t.timestamps
    end

    add_index :machines, :mac, unique: true
  end
end
