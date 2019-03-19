class CreateGp40s < ActiveRecord::Migration[5.2]
  def change
    create_table :gp40s do |t|
      t.references :machine, foreign_key: true
      t.datetime :date
      t.datetime :beginning

      t.timestamps
    end
  end
end
