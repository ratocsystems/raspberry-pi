class AddBeginningToSlopes < ActiveRecord::Migration[5.2]
  def change
    add_column :slopes, :beginning, :datetime, :after => :date
  end
end
