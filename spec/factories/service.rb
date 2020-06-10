FactoryBot.define do
  factory :service do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
    after(:create) do |service|
      create_list(:location, rand(1..2), services: [service])
    end
  end
end