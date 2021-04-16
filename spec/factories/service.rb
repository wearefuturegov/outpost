FactoryBot.define do
  factory :service do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
    after(:create) do |service|
      create_list(:location, 1, services: [service])
      create_list(:link, 3, service: service)
    end
  end
end