FactoryBot.define do
  factory :regular_schedule do
    opens_at { Faker::Time.between_dates(from: Date.today - 1, to: Date.today, period: :morning) }
    closes_at { Faker::Time.between_dates(from: Date.today - 1, to: Date.today, period: :evening) }
    weekday { Faker::Number.between(from: 1, to: 7) }

    association :service
  end
end
