require 'rails_helper'

RSpec.describe Taxonomy, type: :model do
  it { should validate_presence_of(:name) }

  before do
    @organisation = Organisation.create({})
  end

  describe '#filter_by_directory' do
    it 'should return taxonomies that are in specified directory' do
      @directory_a = FactoryBot.create(:directory, name: "Directory A", label: "a")
      @directory_b = FactoryBot.create(:directory, name: "Directory B", label: "b")

      @taxonomy_a = FactoryBot.create(:taxonomy, directories: [@directory_a])
      @taxonomy_b = FactoryBot.create(:taxonomy, directories: [@directory_a])
      @taxonomy_c = FactoryBot.create(:taxonomy, directories: [@directory_b])

      expect(Taxonomy.filter_by_directory('Directory A').count).to eq(2)
      expect(Taxonomy.filter_by_directory('Directory A')).to include(@taxonomy_a, @taxonomy_b)
      expect(Taxonomy.filter_by_directory('Directory B').count).to eq(1)
      expect(Taxonomy.filter_by_directory('Directory B')).to include(@taxonomy_c)
    end
  end
end
