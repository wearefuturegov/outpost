FactoryBot.define do
  factory :service do
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }

    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
    after(:create) do |service|
      create_list(:location, 1, services: [service])
    end
    organisation
  end

  factory :service_with_all_associations, class: 'Service' do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }

    after(:create) do |service|
      create_list(:location, 1, services: [service])
      create_list(:link, 3, service: service)
      create_list(:send_need, 3, services: [service])
      create_list(:service_meta, 4, service: service)
      create_list(:cost_option, 3, service: service)
      create_list(:regular_schedule, 7, service: service)
      create_list(:contact, 4, service: service)
      create_list(:feedback, 10, service: service)
      create_list(:service_taxonomy, 4, service: service)
      create_list(:watch, 2, service: service)
      create_list(:note, 1, service: service)
      create(:local_offer, service: service)
    end
  end
end
