FactoryBot.define do
  factory :gp10 do
    di { Faker::Number.between(0, 255).to_i }
    date { Faker::Time.between(DateTime.now - 10, DateTime.now) }
    beginning { Faker::Time.between(DateTime.now - 10, DateTime.now) }

    association :machine, factory: :machine
  end
end
