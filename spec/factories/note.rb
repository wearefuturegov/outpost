FactoryBot.define do
  factory :note do
    association :user
    association :service
    body { Faker::Lorem.sentence }
  end
end
