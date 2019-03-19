class CreateRotations < ActiveRecord::Migration[5.2]
  def change
    create_table :rotations do |t|
      t.decimal :rpm
      t.decimal :angle
      t.references :machine, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end
