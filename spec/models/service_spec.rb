require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should validate_presence_of(:name) }
  # it { should validate_presence_of(:description) }

  before do
    @organisation = Organisation.create({})
  end

  describe '#save' do
    it 'should populate service taxonomy roots on save' do
      root_taxonomy = Taxonomy.create({ name: 'Root' })
      child1_taxonomy = Taxonomy.create({ name: 'Child 1', parent: root_taxonomy })
      @service = Service.create!({ organisation: @organisation, name: 'Test Service', description: "Test service description", taxonomies: [child1_taxonomy] })
      expect(@service.reload.taxonomies).to match_array([root_taxonomy, child1_taxonomy])
    end

    it 'should not remove taxonomy roots if they were passed as params' do
      root_taxonomy = Taxonomy.create({ name: 'Root' })
      child1_taxonomy = Taxonomy.create({ name: 'Child 1', parent: root_taxonomy })
      @service = Service.create!({ organisation: @organisation, name: 'Test Service', description: "Test service description", taxonomies: [root_taxonomy, child1_taxonomy] })
      expect(@service.reload.taxonomies).to match_array([root_taxonomy, child1_taxonomy])
    end

    it 'should not create additional root service taxonomy relations on subsequent saves' do
      root_taxonomy = Taxonomy.create({ name: 'Root' })
      child1_taxonomy = Taxonomy.create({ name: 'Child 1', parent: root_taxonomy })
      @service = Service.create!({ organisation: @organisation, name: 'Test Service', description: "Test service description", taxonomies: [root_taxonomy, child1_taxonomy] })
      expect(ServiceTaxonomy.where(service_id: @service.id).count).to eq(2)
      @service.save
      expect(ServiceTaxonomy.where(service_id: @service.id).count).to eq(2)
    end
  end

  describe '#destroy' do
    it 'should delete versions and not create a version for destroy event' do
      service = FactoryBot.create(:service, organisation: @organisation)
      create_version = service.versions.first
      expect(create_version.event).to eq('create')

      service.update(name: 'updated name')
      update_version = service.versions.last
      expect(update_version.event).to eq('update')

      service.destroy_associated_data
      service.destroy
      expect { create_version.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { update_version.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(ServiceVersion.where(item_id: service.id, event: 'destroy').size).to eq(0)
    end
  end

  describe '#in_directory' do
    it 'should return services that are in specified directory' do
      @services_directory_a = FactoryBot.create_list(:service, 3, organisation: @organisation, directories: ['Directory A'])
      @services_directory_b = FactoryBot.create_list(:service, 4, organisation: @organisation, directories: ['Directory B'])
      @services_directory_c = FactoryBot.create_list(:service, 2, organisation: @organisation, directories: ['Directory B', 'Directory A'])

      expect(Service.in_directory('Directory A').count).to eq(5)
      expect(Service.in_directory('Directory B').count).to eq(6)
      expect(Service.all.count).to eq(9)
    end
  end
end
