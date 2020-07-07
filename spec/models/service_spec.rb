require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should validate_presence_of(:name) }

  before do
    @organisation = Organisation.create({})
  end

  describe '#save' do
    it 'should populate service taxonomy roots on save' do
      root_taxonomy = Taxonomy.create({ name: 'Root' })
      child1_taxonomy = Taxonomy.create({ name: 'Child 1', parent: root_taxonomy })
      @service = Service.create!({ organisation: @organisation, name: 'Test Service', taxonomies: [child1_taxonomy] })
      expect(@service.taxonomies).to match_array([root_taxonomy, child1_taxonomy])
    end
  end
end