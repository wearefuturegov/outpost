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

  # @TODO finish writing tests
  describe 'handling nested attributes for regular_schedules' do
    # we'll always need an organisation 
    let(:organisation) { FactoryBot.create(:organisation) }

    context 'With no locations' do
      it 'should save regular schedule at all locations' do
        service_attributes = {
          name: 'Service with regular schedule',
          organisation_id: organisation.id,
          regular_schedules_attributes: [
            {
              weekday: 1,
              opens_at: '09:00',
              closes_at: '17:00'
            }
          ]
        }
        service = Service.new(service_attributes)
        expect(service).to be_valid
        service.save
        expect(service.service_at_locations.size).to eq(0)
        expect(service.regular_schedules.size).to eq(1)
        expect(service.regular_schedules.first.weekday).to eq(1)
      end
    end

    context 'With new location' do
      it 'should save regular schedule at all locations' do
        service_attributes = {
          name: 'Service with regular schedule',
          organisation_id: organisation.id,
          locations_attributes: [
            name: 'New location',
            postal_code: 'N1 1AA'
          ],
          regular_schedules_attributes: [
            {
              weekday: 1,
              opens_at: '09:00',
              closes_at: '17:00'
            }
          ]
        }
        service = Service.new(service_attributes)
        expect(service).to be_valid
        service.save
        expect(service.service_at_locations.size).to eq(1)
        expect(service.service_at_locations.first.service_id).to eq(service.id)
        expect(service.regular_schedules.size).to eq(1)
        expect(service.regular_schedules.first.weekday).to eq(1)
        expect(service.regular_schedules.first.service_at_location_id).to eq(nil)
      end

      it 'should save regular schedule at specified locations' do

        service_attributes = {
          name: 'Service with regular schedule',
          organisation_id: organisation.id,
          regular_schedules_attributes: [
            {
              location_object_id: 1234,
              weekday: 1,
              opens_at: '09:00',
              closes_at: '17:00'
            },
            {
              location_object_id: 5678,
              weekday: 2,
              opens_at: '09:00',
              closes_at: '17:00'
            },
            {
              weekday: 3,
              opens_at: '09:00',
              closes_at: '17:00'
            }
          ],
          locations_attributes: [
            {
              name: 'New location', 
              postal_code: 'N1 1AA',
              location_object_id: 1234,
            },
            {
              name: 'New location 2', 
              postal_code: 'N1 1AA',
              location_object_id: 5678,
            }
          ]
        }
        service = Service.new(service_attributes)
        expect(service).to be_valid
        service.save

        
        expect(service.locations.size).to eq(2)
        expect(service.service_at_locations.size).to eq(2)
        expect(service.regular_schedules.size).to eq(3)


        schedules_without_location = service.regular_schedules.select { |rs| rs.service_at_location_id.nil? && rs.weekday == 3 }
        expect(schedules_without_location.size).to eq(1)
        schedules_with_location = service.regular_schedules.select { |rs| rs.service_at_location_id }
        expect(schedules_with_location.size).to eq(2)

        service.locations.each do |location|
          service_at_location = service.service_at_locations.find { |sal| sal.location_id == location.id }
          expect(service_at_location).not_to be_nil

          regular_schedule = service.regular_schedules.find { |rs| rs.service_at_location_id == service_at_location.id }
          expect(regular_schedule).not_to be_nil
        end

      end
    end


    context 'With new and existing location' do
      let(:locations) { FactoryBot.create_list :location, 2 }
      let!(:regular_schedule) { FactoryBot.create(:regular_schedule) }


      it 'should save and update regular schedules at all locations' do

         # make a standard service with a location and a schedule at any location
         service_attributes = {
          name: 'Service with regular schedule',
          organisation_id: organisation.id,
          locations: locations,
          regular_schedules: [regular_schedule]
        }
        service = Service.new(service_attributes)
        service.save

        # add in a new regular schedule at the first location
        # doing this manually as the regular_schedule factory is not set up to handle location_object_id
        # also because the logic for this is tested above
        service_at_location = service.service_at_locations.first
        regular_schedule_at_location = FactoryBot.create(:regular_schedule, service: service, service_at_location_id: service_at_location.id)
        service.regular_schedules << regular_schedule_at_location
        service.save

        # puts "\n\n\n"
        # puts "🔥 Service"
        # puts service.inspect
        # puts "\n\n\n"
        # puts "🔥 Service locations"
        # puts service.locations.inspect
        # puts "\n\n\n"
        # puts "🔥 Service service at locations"
        # puts service.service_at_locations.inspect
        # puts "\n\n\n"
        # puts "🔥 Service regular schedules"
        # puts service.regular_schedules.inspect
        # puts "\n\n\n"

        # check we have everything in order
        expect(service.locations.size).to eq(2)
        expect(service.service_at_locations.size).to eq(2)
        expect(service.regular_schedules.size).to eq(2)

        schedules_without_location = service.regular_schedules.select { |rs| rs.service_at_location_id.nil? }
        expect(schedules_without_location.size).to eq(1)
        schedules_with_location = service.regular_schedules.select { |rs| rs.service_at_location_id }
        expect(schedules_with_location.size).to eq(1)
        
        # now we update things

        # remove the locations from the service
        # should remove the regular_schedules

        # find the location which has associated schedules
        schedule_with_location_service_at_location_id = service.regular_schedules.find { |rs| rs.service_at_location_id }&.service_at_location_id
        schedule_with_location_location_id = service.service_at_locations.find { |sal| sal.id == schedule_with_location_service_at_location_id }&.location_id
        location_with_schedule = service.locations.find { |l| l.id == schedule_with_location_location_id }

        locations_to_be_deleted = service.locations.reject { |l| l.id == location_with_schedule.id }.map(&:id)

        locations_attributes = service.locations.map do |location|
          if location.id == location_with_schedule.id
            { id: location.id }
          else
            { id: location.id, _destroy: true }
          end
        end

        # locations_attributes = service.locations.map do |location|
        #   { id: location.id, _destroy: location.id != location_with_schedule.id }
        # end

        puts locations_attributes.inspect
        service.update(locations_attributes: locations_attributes)

        puts Location.where(id: locations_to_be_deleted).inspect
        puts RegularSchedule.where(service_id: service.id).inspect
        puts "\n\n\n"
        puts "🔥 Service"
        puts service.inspect
        puts "\n\n\n"
        puts "🔥 Service locations"
        puts service.locations.inspect
        puts "\n\n\n"
        puts "🔥 Service service at locations"
        puts service.service_at_locations.inspect
        puts "\n\n\n"
        puts "🔥 Service regular schedules"
        puts service.regular_schedules.inspect
        puts "\n\n\n"
        
        expect(service.locations.size).to eq(1)
        expect(service.locations.first.id).to eq(location_with_schedule.id)
        expect(service.service_at_locations.size).to eq(1)
        expect(service.regular_schedules.size).to eq(1)
  






      end

    end

  end




  # puts "Service ID: #{service.id}" 
  # puts service.inspect
  # puts service.locations.inspect
  # puts service.service_at_locations.inspect
  # puts service.regular_schedules.inspect


    # context 'with service_at_location_id' do
    #   it 'is valid with valid attributes' do
    #     service_attributes = {
    #       name: 'Service with regular schedule',
    #       organisation_id: organisation.id,
    #       regular_schedules_attributes: [
    #         {
    #           service_at_location_id: service_at_location.id,
    #           weekday: 'Monday',
    #           opens_at: '09:00',
    #           closes_at: '17:00'
    #         }
    #       ]
    #     }
    #     service = Service.new(service_attributes)
    #     expect(service).to be_valid
    #     service.save
    #     puts "Service ID: #{service.id}" 
    #     puts service.inspect
    #   end
    # end

    # context 'with location_id and service_id' do
    #   let(:location) { FactoryBot.create(:location) }
    # let(:service_at_location) { FactoryBot.create(:service_at_location, service: subject, location: location) }
    #   it 'is valid with valid attributes' do
    #     service_attributes = {
    #       name: 'Service with regular schedule',
    #       organisation_id: organisation.id,
    #       regular_schedules_attributes: [
    #         {
    #           location_id: location.id,
    #           service_id: subject.id,
    #           weekday: 'Tuesday',
    #           opens_at: '10:00',
    #           closes_at: '18:00'
    #         }
    #       ]
    #     }
    #     service = Service.new(service_attributes)
    #     expect(service).to be_valid
    #     service.save
    #   end
    # end
  # end


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
end
