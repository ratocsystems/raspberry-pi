FactoryBot.define do
  factory :survey do
    distance { Faker::Number.decimal(3.2) }
    date { Faker::Time.between(DateTime.now - 10, DateTime.now) }
    beginning { Faker::Time.between(DateTime.now - 10, DateTime.now) }

    association :machine, factory: :machine
  end
end
