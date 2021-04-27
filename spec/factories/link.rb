FactoryBot.define do
  factory :link do
    label { Faker::Company.name }
    url { Faker::Internet.url }
  end
end