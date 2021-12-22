FactoryBot.define do
  factory :ofsted_item do
    provider_name { Faker::Company.name }
    setting_name { Faker::Educator.primary_school }
    reference_number { Faker::Internet.uuid }
    provision_type { ['HCR', 'CMR', 'CCN', 'RPP', 'CCD'].sample }
    childcare_period { [] }

    trait :new do
      status { 'new' }
    end

    trait :changed do
      status { 'changed' }
    end

    trait :deleted do
      status { 'deleted' }
    end
  end
end
