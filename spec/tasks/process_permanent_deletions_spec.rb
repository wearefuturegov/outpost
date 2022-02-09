require "rails_helper"
Rails.application.load_tasks

describe "process permanent deletions" do
  let(:organisation) { FactoryBot.create(:organisation) }
  let(:services) { FactoryBot.create_list(:service_with_all_associations, 3, organisation: organisation) }
  let(:service_for_deletion) { services.last }

  before do
    service_for_deletion.update(discarded_at: Time.now - 40.days, marked_for_deletion: Time.now - 31.days)
    service_for_deletion.reload
  end

  after(:each) do
    Rake::Task["process_permanent_deletions"].reenable
  end

  it "deletes services and associations" do
    send_need_1 = service_for_deletion.send_needs.first
    send_need_2 = service_for_deletion.send_needs.last

    send_need_1_service_count = send_need_1.services.count
    send_need_2_service_count = send_need_2.services.count

    service_at_location = service_for_deletion.service_at_locations.first
    service_link = service_for_deletion.links.last
    service_meta = service_for_deletion.meta.first
    service_cost_option = service_for_deletion.cost_options.last
    service_reg_sched = service_for_deletion.regular_schedules.first
    service_contact = service_for_deletion.contacts.first
    service_feedback = service_for_deletion.feedbacks.first
    service_taxonomy = service_for_deletion.service_taxonomies.first
    service_watch = service_for_deletion.watches.first
    service_note = service_for_deletion.notes.first
    service_local_offer = service_for_deletion.local_offer

    Rake::Task["process_permanent_deletions"].invoke
    expect { service_for_deletion.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_at_location.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_link.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_meta.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_cost_option.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_reg_sched.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_contact.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_feedback.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_taxonomy.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_watch.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_note.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { service_local_offer.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(Service.all.count).to eq(2)

    expect(send_need_1.services.count).to eq(send_need_1_service_count - 1)
    expect(send_need_2.services.count).to eq(send_need_2_service_count - 1)
  end

  describe 'deleting users that have created notes' do
    let(:users_for_deletion) { FactoryBot.create_list(:user, 3, discarded_at: Time.now - 40.days, marked_for_deletion: Time.now - 31.days) }
    let(:user_with_note) { users_for_deletion.first }
    let!(:version) { FactoryBot.create :service_version, item_type: 'Service', item_id: Service.first.id, whodunnit: user_with_note.id.to_s, event: 'update' }

    before do
      user_with_note.notes.create!(service: services.first, body: 'This is a note')
    end

    it 'deletes all the users and updates associated notes and versions' do
      users_count = User.all.count
      note = user_with_note.notes.first

      expect(note.deleted_user_name).to eq(nil)
      expect(version.reload.whodunnit).to eq(user_with_note.id.to_s)

      Rake::Task["process_permanent_deletions"].invoke

      expect(User.all.count).to eq(users_count - 3)
      expect(note.reload.user).to eq(nil)
      expect(note.reload.deleted_user_name).to eq(user_with_note.display_name)
      expect(version.reload.whodunnit).to eq(user_with_note.display_name)
    end
  end
end
