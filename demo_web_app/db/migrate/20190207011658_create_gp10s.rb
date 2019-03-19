class CreateGp10s < ActiveRecord::Migration[5.2]
  def change
    create_table :gp10s do |t|
      t.integer :di
      t.references :machine, foreign_key: true
      t.datetime :date
      t.datetime :beginning

      t.timestamps
    end
  end
end
