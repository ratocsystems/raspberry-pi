FactoryBot.define do
  factory :fall do
    count { Faker::Number.number(2).to_i }
    date { Faker::Time.between(DateTime.now - 10, DateTime.now) }
    beginning { Faker::Time.between(DateTime.now - 10, DateTime.now) }

    association :machine, factory: :machine
  end
end
