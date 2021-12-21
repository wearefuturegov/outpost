require 'rails_helper'

RSpec.describe TaxonomySerializer do
  let(:taxonomy) { FactoryBot.create :taxonomy }
  subject { described_class.new(taxonomy) }

  it "includes the expected attributes" do
    expect(subject.attributes.keys).
      to contain_exactly(
        :id,
        :name,
        :parent_id,
        :slug,
      )
  end
end
