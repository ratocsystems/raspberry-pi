class AddIndexToAd < ActiveRecord::Migration[5.2]
  def change
    add_index  :ads, [:gp40_id, :channel], unique: true
  end
end
