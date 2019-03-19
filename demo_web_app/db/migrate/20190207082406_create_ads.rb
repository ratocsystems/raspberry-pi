class CreateAds < ActiveRecord::Migration[5.2]
  def change
    create_table :ads do |t|
      t.references :gp40, foreign_key: true
      t.integer :channel
      t.integer :value
      t.integer :range

      t.timestamps
    end
  end
end
