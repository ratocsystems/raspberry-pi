class Gp40 < ApplicationRecord
  include CommonModule
  belongs_to :machine
  has_many :ads

  attr_accessor :channel
end
