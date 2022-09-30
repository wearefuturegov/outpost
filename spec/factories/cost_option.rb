FactoryBot.define do
  factory :cost_option do
    option { Faker::Lorem.sentence }
    amount { Faker::Number.number }

    association :service
  end
end
