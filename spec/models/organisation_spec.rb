require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should allow_value(nil).for(:name) }
  it { should allow_value('Some Name').for(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(2).is_at_most(100).allow_nil }

  #  This tests the behavior that multiple organisations can have a nil name.
  it 'allows nil names' do
    first = Organisation.create!(name: nil)
    second = Organisation.new(name: nil)

    expect(second).to be_valid
  end


  it 'Does not allow duplicate names' do
    first = Organisation.create!(name: "Organisation 1")
    second = Organisation.new(name: "Organisation 1")

    expect(second).to be_invalid
  end
end
