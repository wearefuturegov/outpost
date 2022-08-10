FactoryBot.define do
  factory :custom_field do
    key { Faker::Lorem.sentence }
    field_type { 'text' }
    custom_field_section

    trait :number do
      field_type { 'number' }
    end

    trait :checkbox do
      field_type { 'checkbox' }
    end

    trait :date do
      field_type { 'date' }
    end

    trait :select do
      field_type { 'select' }
    end
  end
end
