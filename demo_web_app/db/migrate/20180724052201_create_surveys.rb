class CreateSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.decimal :distance
      t.references :machine, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end
