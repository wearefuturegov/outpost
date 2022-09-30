require 'rails_helper'

RSpec.describe CostOptionSerializer do
  let(:cost_option) { FactoryBot.create :cost_option }
  subject { described_class.new(cost_option) }

  it "includes the expected attributes" do
    expect(subject.attributes.keys).
      to contain_exactly(
        :id,
        :option,
        :amount,
        :cost_type
      )
  end

end
