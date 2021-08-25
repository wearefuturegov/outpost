require 'rails_helper'

RSpec.describe Taxonomy, type: :model do
  it { should validate_presence_of(:name) }

  before do
    @organisation = Organisation.create({})
  end

  describe '#filter_by_directory' do
    it 'should return taxonomies that are in specified directory' do
      @taxonomy_a = FactoryBot.create(:taxonomy)
      @taxonomy_b = FactoryBot.create(:taxonomy)
      @taxonomy_c = FactoryBot.create(:taxonomy)

      @services = FactoryBot.create_list(:service, 3, organisation: @organisation, taxonomies: [@taxonomy_a, @taxonomy_b], directory_list: 'Directory A')
      @services = FactoryBot.create_list(:service, 5, organisation: @organisation, taxonomies: [@taxonomy_c], directory_list: 'Directory B')

      expect(Taxonomy.filter_by_directory('Directory A').count).to eq(2)
      expect(Taxonomy.filter_by_directory('Directory A')).to include(@taxonomy_a, @taxonomy_b)
      expect(Taxonomy.filter_by_directory('Directory B').count).to eq(1)
      expect(Taxonomy.filter_by_directory('Directory B')).to include(@taxonomy_c)
    end
  end
end
