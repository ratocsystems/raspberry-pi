class AddBeginningToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :beginning, :datetime, :after => :date
  end
end
