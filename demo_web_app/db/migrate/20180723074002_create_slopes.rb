class CreateSlopes < ActiveRecord::Migration[5.2]
  def change
    create_table :slopes do |t|
      t.integer :x
      t.integer :y
      t.integer :z
      t.references :machine, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end
