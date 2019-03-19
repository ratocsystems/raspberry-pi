class CreateWbgts < ActiveRecord::Migration[5.2]
  def change
    create_table :wbgts do |t|
      t.decimal :black
      t.decimal :dry
      t.decimal :wet
      t.decimal :humidity
      t.decimal :wbgt_data
      t.references :machine, foreign_key: true
      t.datetime :date
      t.datetime :beginning

      t.timestamps
    end
  end
end
