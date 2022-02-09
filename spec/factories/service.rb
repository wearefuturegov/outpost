FactoryBot.define do
  factory :service do
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }

    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
    after(:create) do |service|
      create(:location, services: [service])
    end
    organisation
  end

  factory :service_with_all_associations, class: 'Service' do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }

    after(:create) do |service|
      create(:location, services: [service])
      create(:link, service: service)
      create(:send_need, services: [service])
      create(:service_meta, service: service)
      create(:cost_option, service: service)
      create_list(:regular_schedule, 7, service: service)
      create(:contact, service: service)
      create(:feedback, service: service)
      create(:service_taxonomy, service: service)
      create(:watch, service: service)
      create(:note, service: service)
      create(:local_offer, service: service)
    end
  end
end
