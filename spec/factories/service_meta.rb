FactoryBot.define do
  factory :service_meta do
    label { Faker::Lorem.sentence }
    value { Faker::Number.number }
  end
end