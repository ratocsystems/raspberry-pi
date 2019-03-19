class CreateFalls < ActiveRecord::Migration[5.2]
  def change
    create_table :falls do |t|
      t.integer :count
      t.references :machine, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end
