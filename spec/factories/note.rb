FactoryBot.define do
  factory :note do
    user factory: :user
    body { Faker::Lorem.sentence }
  end
end