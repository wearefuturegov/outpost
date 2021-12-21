require 'rails_helper'

RSpec.describe ContactSerializer do
  let(:contact) { FactoryBot.create :contact }
  subject { described_class.new(contact) }

  it "includes the expected attributes" do
    expect(subject.attributes.keys).
      to contain_exactly(
        :id,
        :name,
        :email,
        :phone,
        :title
      )
  end
end
