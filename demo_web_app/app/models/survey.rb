class Survey < ApplicationRecord
  include CommonModule
  belongs_to :machine

end
