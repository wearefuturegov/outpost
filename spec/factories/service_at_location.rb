FactoryBot.define do
  factory :service_at_location do
    association :location
    association :service
  end
end
