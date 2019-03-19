class AddBeginningToFalls < ActiveRecord::Migration[5.2]
  def change
    add_column :falls, :beginning, :datetime, :after => :date
  end
end
