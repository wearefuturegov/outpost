# spec/tasks/update_public_index_spec.rb
require 'rails_helper'
require 'rake'


describe 'update_public_index task' do

  let(:task) { Rake::Task['update_public_index'] }
  let(:collection) { double('indexed_services') }

  before do
    Rake.application.rake_require('tasks/update_public_index')
    Rake::Task.define_task(:environment)

    database = double('Database')
    allow(database).to receive(:[]).with(:indexed_services).and_return(collection)
    allow(Mongo::Client).to receive(:new).and_return(double('Mongo::Client', database: database))
  end

  after do
    task.reenable # Re-enable the task after each test
  end

  context 'when adding services to the Mongo database' do
    let!(:service_active) { FactoryBot.create_list(:service, 3) }
    let!(:service_temporarily_closed) { FactoryBot.create_list(:service, 3, temporarily_closed: true) }
    let!(:service_scheduled) { FactoryBot.create_list(:service, 3, visible_from: Date.today + 2) }



    before do
      service_active.each do |service|
        serialized_service = IndexedServicesSerializer.new(service).as_json
        allow(collection).to receive(:find_one_and_update).with(
          { id: service.id },
          serialized_service,
          { upsert: true }
        )
      end

      service_temporarily_closed.each do |service|
        serialized_service = IndexedServicesSerializer.new(service).as_json
        allow(collection).to receive(:find_one_and_update).with(
          { id: service.id },
          serialized_service,
          { upsert: true }
        )
      end

      service_scheduled.each do |service|
        serialized_service = IndexedServicesSerializer.new(service).as_json
        allow(collection).to receive(:find_one_and_update).with(
          { id: service.id },
          serialized_service,
          { upsert: true }
        )
      end

      indexed_ids = service_active.map(&:id) + service_temporarily_closed.map(&:id) + service_scheduled.map(&:id)
      missed_services = [
        { 'id' => 'missed_service_1' },
        { 'id' => 'missed_service_2' }
      ]
      allow(collection).to receive(:find).with({ id: { '$nin': indexed_ids.sort } }).and_return(missed_services)
      allow(collection).to receive(:delete_many).with({ id: { '$in': ['missed_service_1', 'missed_service_2'] } }).and_return(double('result', deleted_count: 2))  
    end

    it 'adds services to the Mongo database and removes any it has missed' do
      expect { task.invoke }.to output(
        match(/2 services exist in mongo but not in outpost, deleting.../)
        .and match(/2 unaccounted for services deleted./)
        .and match(/ 👉 9 updated or created/)
        .and match(/ 👉 0 skipped/)
        .and match(/ 👉 0 deleted/)
        .and match(/ 👉 3 active services, 3 created or updated/)
        .and match(/ 👉 3 temporarily_closed services, 3 created or updated/)
        .and match(/ 👉 3 scheduled services, 3 created or updated/)
        .and match(/ 👉 0 archived services, 0 deleted/)
        .and match(/ 👉 0 expired services, 0 deleted/)
        .and match(/ 👉 0 invisible services, 0 deleted/)
        .and match(/ 👉 0 marked_for_deletion services, 0 deleted/)
        .and match(/ 👉 0 pending services, 0 created or updated./)
        ).to_stdout
    end

  end

  context 'when removing services from the Mongo database' do
    let!(:service_archived) { FactoryBot.create_list(:service, 3, discarded_at: 1.day.ago) }
    let!(:service_expired) { FactoryBot.create_list(:service, 3, visible_to: Date.today - 2) }
    let!(:service_invisible) { FactoryBot.create_list(:service, 3, visible: false) }
    let!(:service_marked_for_deletion) { FactoryBot.create_list(:service, 3, marked_for_deletion: Time.now) }
    

    before do
      service_archived.each do |service|
        allow(collection).to receive(:find_one_and_delete).with(
          { id: service.id }
        ).and_return(service.attributes)
      end

      service_expired.each do |service|
        allow(collection).to receive(:find_one_and_delete).with(
          { id: service.id }
        ).and_return(service.attributes)
      end

      service_invisible.each do |service|
        allow(collection).to receive(:find_one_and_delete).with(
          { id: service.id }
        ).and_return(service.attributes)
      end

      service_marked_for_deletion.each do |service|
        allow(collection).to receive(:find_one_and_delete).with(
          { id: service.id }
        ).and_return(service.attributes)
      end

      allow(collection).to receive(:find).with({ id: { '$nin': [] } })
    end


    it 'removes services from the Mongo database' do
      expect { task.invoke }.to output(
        match(/No unaccounted for services left in the index./)
        .and match(/ 👉 0 updated or created/)
        .and match(/ 👉 0 skipped/)
        .and match(/ 👉 12 deleted/)
        .and match(/ 👉 0 active services, 0 created or updated/)
        .and match(/ 👉 0 temporarily_closed services, 0 created or updated/)
        .and match(/ 👉 0 scheduled services, 0 created or updated/)
        .and match(/ 👉 3 archived services, 3 deleted/)
        .and match(/ 👉 3 expired services, 3 deleted/)
        .and match(/ 👉 3 invisible services, 3 deleted/)
        .and match(/ 👉 3 marked_for_deletion services, 3 deleted/)
        .and match(/ 👉 0 pending services, 0 created or updated./)
        ).to_stdout
    end

  end

  context 'when dealing with pending services' do
    let!(:service_pending_with_no_snapshot) { FactoryBot.create(:service, approved: false) }
    let!(:service_pending_with_no_approved_snapshot) { FactoryBot.create(:service, approved: false) }
    let!(:service_pending_with_approved_snapshot_but_not_public) { FactoryBot.create(:service, approved: false, visible: false, discarded_at: 1.day.ago) }
    let!(:service_pending_with_approved_snapshot) { FactoryBot.create(:service, approved: false) }

    before do
      # create another version but still don't approve it
      service_pending_with_no_approved_snapshot.update(updated_at: Date.today)

      # approve a version, then change it so its pending again
      service_pending_with_approved_snapshot.update(approved: true)
      service_pending_with_approved_snapshot.update(updated_at: Date.today, approved: false)

      # approve a version, then change it so its pending again
      service_pending_with_approved_snapshot_but_not_public.update(approved: true)
      service_pending_with_approved_snapshot_but_not_public.update(updated_at: Date.today, approved: false)
    end

    it 'doesn\'t add any that are unapproved' do
       # no snapshot at all
       allow(collection).to receive(:find_one_and_update).with(
        { id: service_pending_with_no_snapshot.id },
        IndexedServicesSerializer.new(service_pending_with_no_snapshot).as_json,
        { upsert: true }
      )

      # snapshot but not approved
      allow(collection).to receive(:find_one_and_update).with(
        { id: service_pending_with_no_approved_snapshot.id },
        IndexedServicesSerializer.new(service_pending_with_no_approved_snapshot).as_json,
        { upsert: true }
      )

      # approved - it's approved but not visible so it wont be added
      allow(collection).to receive(:find_one_and_update).with(
        { id: service_pending_with_approved_snapshot_but_not_public.id },
        IndexedServicesSerializer.new(Service.from_hash(service_pending_with_approved_snapshot_but_not_public.last_approved_snapshot.object)).as_json,
        { upsert: true }
      )

      # approved - it's approved, it should be added
      allow(collection).to receive(:find_one_and_update).with(
        { id: service_pending_with_approved_snapshot.id },
        IndexedServicesSerializer.new(Service.from_hash(service_pending_with_approved_snapshot.last_approved_snapshot.object)).as_json,
        { upsert: true }
      )


      indexed_ids = [service_pending_with_approved_snapshot.id]
      allow(collection).to receive(:find).with({ id: { '$nin': indexed_ids.sort } })

      expect { task.invoke }.to output(
        match(/No unaccounted for services left in the index./)
        .and match(/ 👉 1 updated or created/)
        .and match(/ 👉 3 skipped/)
        .and match(/ 👉 0 deleted/)
        .and match(/ 👉 0 active services, 0 created or updated/)
        .and match(/ 👉 0 temporarily_closed services, 0 created or updated/)
        .and match(/ 👉 0 scheduled services, 0 created or updated/)
        .and match(/ 👉 0 archived services, 0 deleted/)
        .and match(/ 👉 0 expired services, 0 deleted/)
        .and match(/ 👉 0 invisible services, 0 deleted/)
        .and match(/ 👉 0 marked_for_deletion services, 0 deleted/)
        .and match(/ 👉 4 pending services, 1 created or updated./)
        ).to_stdout
    end

  end 

end

describe 'develop update_public_index task' do

  let(:task) { Rake::Task['update_public_index'] }
  let(:collection) { double('indexed_services') }

  before do
    Rake.application.rake_require('tasks/update_public_index')
    Rake::Task.define_task(:environment)

    database = double('Database')
    allow(database).to receive(:[]).with(:indexed_services).and_return(collection)
    allow(Mongo::Client).to receive(:new).and_return(double('Mongo::Client', database: database))
  end

  after do
    task.reenable # Re-enable the task after each test
  end


  let!(:service_active) { FactoryBot.create_list(:service, 3) }
  let!(:service_temporarily_closed) { FactoryBot.create_list(:service, 3, temporarily_closed: true) }
  let!(:service_scheduled) { FactoryBot.create_list(:service, 3, visible_from: Date.today + 2) }

  let!(:service_archived) { FactoryBot.create_list(:service, 3, discarded_at: 1.day.ago) }
  let!(:service_expired) { FactoryBot.create_list(:service, 3, visible_to: Date.today - 2) }
  let!(:service_invisible) { FactoryBot.create_list(:service, 3, visible: false) }
  let!(:service_marked_for_deletion) { FactoryBot.create_list(:service, 3, marked_for_deletion: Time.now) }

  let!(:service_pending_with_no_snapshot) { FactoryBot.create(:service, approved: false) }
  let!(:service_pending_with_no_approved_snapshot) { FactoryBot.create(:service, approved: false) }
  let!(:service_pending_with_approved_snapshot_but_not_public) { FactoryBot.create(:service, approved: false, visible: false, discarded_at: 1.day.ago) }
  let!(:service_pending_with_approved_snapshot) { FactoryBot.create(:service, approved: false) }

  before do
    # create another version but still don't approve it
    service_pending_with_no_approved_snapshot.update(updated_at: Date.today)

    # approve a version, then change it so its pending again
    service_pending_with_approved_snapshot.update(approved: true)
    service_pending_with_approved_snapshot.update(updated_at: Date.today, approved: false)

    # approve a version, then change it so its pending again
    service_pending_with_approved_snapshot_but_not_public.update(approved: true)
    service_pending_with_approved_snapshot_but_not_public.update(updated_at: Date.today, approved: false)
  end

  it 'runs' do
    skip("is used for testing purposes") 
    expect(collection).to receive(:find_one_and_update).at_least(:once)
    expect(collection).to receive(:find_one_and_delete).at_least(:once)
    expect(collection).to receive(:find).at_least(:once)
    task.invoke
  end

end
