require 'rails_helper'

RSpec.describe User, type: :model do

  let!(:user) { FactoryBot.build(:user) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }

  it "won't save without password" do
    user.password = nil
    expect(user.save).to eq(false)
  end
end
