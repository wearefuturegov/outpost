require 'rails_helper'

RSpec.describe Service, type: :model do
  subject { FactoryBot.create :service }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

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
          .to have_enqueued_mail(ServiceMailer, :notify_watcher_email).twice
      end
    end

    context 'with a deactivated watcher' do
      let!(:watch) { FactoryBot.create :watch, service: subject }

      before do
        watch.user.update(discarded_at: 1.day.ago)
      end

      it 'does not send an email' do
        expect { subject.reload.notify_watchers }
          .to_not have_enqueued_mail(ServiceMailer, :notify_watcher_email)
      end
    end
  end


  # a new location is added in the UI 
  # in the admin env this location doesn't have a service_at_location entry yet which a regular_schedule assigned to that location will need
  # we can add regular schedules assigned to locations in two ways
  # 1. location exists therefore service_at_location exists and we can pass through service_at_location_id to the regular_schedule
  # 2. location doesn't exist therefore service_at_location doesn't exist and we can pass through location_object_id to the regular_schedule, 
  #    this is used to find the corresponding location and service_at_location_id after the service (and locations) have been saved


  describe '#update_regular_schedules' do
    let(:location) { FactoryBot.create(:location, location_object_id: 'loc123') }
    let(:service_at_location) { FactoryBot.create(:service_at_location, service: subject, location: location) }
    let!(:regular_schedule) { FactoryBot.create(:regular_schedule, service: subject) }

    before do
      # Ensure the associations are set up correctly
      subject.locations << location
      subject.service_at_locations << service_at_location
      subject.regular_schedules << regular_schedule
    end

    context 'Location exists already'  do


      it 'saves the regular schedule at \'all locations\'' do 
        subject.update(regular_schedules: [regular_schedule])
        expect(subject.reload.regular_schedules).to match_array([regular_schedule])
        expect(subject.reload.regular_schedules.first.service_at_location_id).to be_nil
      end

      it 'saves the regular schedule at a specific location' do
        regular_schedule.update(service_at_location_id: service_at_location.id)
        subject.update(regular_schedules: [regular_schedule])
        expect(subject.reload.regular_schedules).to match_array([regular_schedule])
        expect(subject.reload.regular_schedules.first.service_at_location_id).to eq(service_at_location.id)
      end

    end


    context 'Location doesnt yet exist'  do
      it 'saves the regular schedule at a specific location' do
        regular_schedule.update(location_object_id: 'loc123')
        location.update(location_object_id: 'loc123')
        subject.update(locations: [location], regular_schedules: [regular_schedule])
        newServiceAtLocation = ServiceAtLocation.find_by(location_id: location.id, service_id: subject.reload.id)
        expect(subject.reload.regular_schedules).to match_array([regular_schedule])
        expect(subject.reload.regular_schedules.first.service_at_location_id).to eq(newServiceAtLocation.id)
      end

      it 'saves the regular schedule at \'all locations\' if no location is found' do
        regular_schedule.update(location_object_id: 'loc1234')
        location.update(location_object_id: 'loc123')
        subject.update(locations: [location], regular_schedules: [regular_schedule])
        newServiceAtLocation = ServiceAtLocation.find_by(location_id: location.id, service_id: subject.reload.id)
        expect(subject.reload.regular_schedules).to match_array([regular_schedule])
        expect(subject.reload.regular_schedules.first.service_at_location_id).to be_nil
      end
    end
  end

end
