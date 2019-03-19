FactoryBot.define do
  factory :ad do
    channel { Faker::Number.between(0, 7).to_i }
    value { Faker::Number.between(0, 0xFFF).to_i }
    range { Faker::Number.between(0, 8).to_i }

    association :gp40, factory: :gp40
  end
end
