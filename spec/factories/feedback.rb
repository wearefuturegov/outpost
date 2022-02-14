FactoryBot.define do
  factory :feedback do
    body { Faker::Lorem.sentence }
    topic { ['out-of-date', 'something-else', 'extra-information-to-add', 'service-has-closed'].sample }

    service
  end
end
