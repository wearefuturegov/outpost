require 'rails_helper'

RSpec.describe User, type: :model do

    let!(:user) { FactoryBot.build(:user) }

    # it { should validate_presence_of(:email) }

    it "won't save without email" do
      user.email = nil
      expect(user.save).to eq(false)
    end

    it "won't save without password" do
      user.password = nil
      expect(user.save).to eq(false)
    end
end
