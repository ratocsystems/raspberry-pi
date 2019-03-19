class Ad < ApplicationRecord
  belongs_to :gp40

  validates :gp40_id, uniqueness: { scope: [:channel] }
  validates :channel, :inclusion => 0..7
  validates :range, :inclusion => 0..8
  validates :value, :inclusion => 0..0xFFF
end
