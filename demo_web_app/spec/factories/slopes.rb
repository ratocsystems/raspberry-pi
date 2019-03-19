FactoryBot.define do
  factory :slope do
    x { Faker::Number.between(-60000, 60000) }
    y { Faker::Number.between(-60000, 60000) }
    z { Faker::Number.between(-60000, 60000) }
    date { Faker::Time.between(DateTime.now - 10, DateTime.now) }
    beginning { Faker::Time.between(DateTime.now - 10, DateTime.now) }

    association :machine, factory: :machine
  end
end
