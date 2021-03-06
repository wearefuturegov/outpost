FactoryBot.define do
  factory :service do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
    after(:create) do |service|
      create_list(:location, 1, services: [service])
    end
  end
end