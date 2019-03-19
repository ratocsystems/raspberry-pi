FactoryBot.define do
  factory :machine do
    mac { Faker::Internet.mac_address }
  end
end
