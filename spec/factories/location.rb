FactoryBot.define do
  factory :location do
    name { Faker::Address.street_name }
    description { Faker::Lorem.paragraph }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    address_1 { Faker::Address.street_address }
    city { Faker::Address.city }
    state_province { Faker::Address.state }
    postal_code { Faker::Address.postcode }
    country { Faker::Address.country }
  end
end