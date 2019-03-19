class AddBeginningToRotations < ActiveRecord::Migration[5.2]
  def change
    add_column :rotations, :beginning, :datetime, :after => :date
  end
end
