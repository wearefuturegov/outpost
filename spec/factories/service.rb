FactoryBot.define do
  factory :service do
    name { Faker::Lorem.word }
  end
end