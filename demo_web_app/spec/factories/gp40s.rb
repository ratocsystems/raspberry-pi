FactoryBot.define do
  factory :gp40 do
    date { Faker::Time.between(DateTime.now - 10, DateTime.now) }
    beginning { Faker::Time.between(DateTime.now - 10, DateTime.now) }

    association :machine, factory: :machine
  end
end
