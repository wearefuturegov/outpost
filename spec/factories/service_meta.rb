FactoryBot.define do
  factory :service_meta do
    key { Faker::Lorem.sentence }
    value { Faker::Number.number }
  end
end