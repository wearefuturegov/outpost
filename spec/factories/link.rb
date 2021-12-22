FactoryBot.define do
  factory :link do
    label { ['Facebook', 'YouTube', 'Twitter', 'Instagram', 'LinkedIn'].sample }
    url { Faker::Internet.url }
  end
end
