FactoryBot.define do
  factory :wbgt do
    black { Faker::Number.decimal(2, 1) }
    dry { Faker::Number.decimal(2, 1) }
    wet { Faker::Number.decimal(2, 1) }
    humidity { Faker::Number.decimal(2, 1) }
    wbgt_data { Faker::Number.decimal(2, 1) }
    date { Faker::Time.between(DateTime.now - 10, DateTime.now) }
    beginning { Faker::Time.between(DateTime.now - 10, DateTime.now) }

    association :machine, factory: :machine
  end
end
