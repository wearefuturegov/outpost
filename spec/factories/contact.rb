FactoryBot.define do
  factory :contact do
    name { Faker::Name.name }
    title { Faker::Lorem.word }
    visible { [true, false].sample }
  end
end