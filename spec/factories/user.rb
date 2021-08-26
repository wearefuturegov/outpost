FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(domain: 'example.com') }
    first_name {Faker::Name.first_name }
    last_name {Faker::Name.last_name }
    password { "password123A" }

    trait :deactivated do
      discarded_at { Time.now }
    end

    trait :services_admin do
      admin { true }
    end

    trait :ofsted_viewer do
      admin { true }
      admin_ofsted { true }
    end

    trait :user_manager do
      admin { true }
      admin_users { true }
      admin_ofsted { true }
    end

    trait :superadmin do
      admin { true }
      admin_users { true }
      admin_ofsted { true }
      admin_manage_ofsted_access { true }
    end

  end
end
