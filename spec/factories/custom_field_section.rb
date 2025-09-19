FactoryBot.define do
  factory :custom_field_section do
    name { Faker::Lorem.sentence }
  end

  trait :expose_in_public_api do
      api_public { true }
  end
end
