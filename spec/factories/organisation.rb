FactoryBot.define do
  factory :organisation do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }

    factory :organisation_with_services do
      name { Faker::Lorem.word }
      description { Faker::Lorem.paragraph }
      url { Faker::Internet.url }

      after(:create) do |organisation|
        create_list(:service, 5, organisation: organisation)
      end
    end
  end
end