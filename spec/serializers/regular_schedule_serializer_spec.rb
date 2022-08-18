require 'rails_helper'

RSpec.describe RegularScheduleSerializer do
  let(:regular_schedule) { FactoryBot.create :regular_schedule }
  subject { described_class.new(regular_schedule) }

  it "includes the expected attributes" do
    expect(subject.attributes.keys).
      to contain_exactly(
        :id,
        :weekday,
        :opens_at,
        :closes_at
      )
  end

end
