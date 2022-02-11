require 'rails_helper'

RSpec.describe Service, type: :model do
  subject { FactoryBot.create :service }

  it { should validate_presence_of(:name) }

  describe '#save' do
    it 'should populate service taxonomy roots on save' do
      root_taxonomy = Taxonomy.create({ name: 'Root' })
      child1_taxonomy = Taxonomy.create({ name: 'Child 1', parent: root_taxonomy })
      subject.update(taxonomies: [child1_taxonomy])
      expect(subject.reload.taxonomies).to match_array([root_taxonomy, child1_taxonomy])
    end

    it 'should not remove taxonomy roots if they were passed as params' do
      root_taxonomy = Taxonomy.create({ name: 'Root' })
      child1_taxonomy = Taxonomy.create({ name: 'Child 1', parent: root_taxonomy })
      subject.update(taxonomies: [root_taxonomy, child1_taxonomy])
      expect(subject.reload.taxonomies).to match_array([root_taxonomy, child1_taxonomy])
    end

    it 'should not create additional root service taxonomy relations on subsequent saves' do
      root_taxonomy = Taxonomy.create({ name: 'Root' })
      child1_taxonomy = Taxonomy.create({ name: 'Child 1', parent: root_taxonomy })
      subject.update(taxonomies: [child1_taxonomy])
      expect(ServiceTaxonomy.where(service_id: subject.id).count).to eq(2)
      subject.save
      expect(ServiceTaxonomy.where(service_id: subject.id).count).to eq(2)
    end

  end

  describe '#destroy' do
    it 'should delete versions and not create a version for destroy event' do
      create_version = subject.versions.first
      expect(create_version.event).to eq('create')

      subject.update(name: 'updated name')
      update_version = subject.versions.first
      expect(update_version.event).to eq('update')

      subject.destroy_associated_data
      subject.destroy
      expect { create_version.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { update_version.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(ServiceVersion.where(item_id: subject.id, event: 'destroy').size).to eq(0)
    end
  end

  describe '#in_directory' do
    it 'should return services that are in specified directory' do
      directory_a = FactoryBot.create(:directory, name: "Directory A", label: "a")
      directory_b = FactoryBot.create(:directory, name: "Directory B", label: "b")

      subject.update(directories: [directory_a, directory_b])
      FactoryBot.create(:service, directories: [directory_a])
      FactoryBot.create_list(:service, 2, directories: [directory_b])

      expect(Service.in_directory('Directory A').count).to eq(2)
      expect(Service.in_directory('Directory B').count).to eq(3)
      expect(Service.all.count).to eq(4)
    end
  end

  describe '#notify_watchers' do
    context 'when the service is being watched' do
      let!(:watches) { FactoryBot.create_list :watch, 2, service: subject }

      it 'sends an email all watchers' do
        expect { subject.reload.notify_watchers }
          .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by 2
      end
    end
  end
end
