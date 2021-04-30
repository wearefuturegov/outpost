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
      expect(@service.taxonomies).to match_array([root_taxonomy, child1_taxonomy])
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
end