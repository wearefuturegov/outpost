FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(domain: 'example.com') }
    first_name {Faker::Name.first_name }
    last_name {Faker::Name.last_name }
    password { "password123A" }

    trait :admin do
      admin { true }
    end

    trait :deactivated do
      discarded_at { Time.now }
    end
  end
end
