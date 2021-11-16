require "rails_helper"
Rails.application.load_tasks

describe "process permanent deletions" do

  before do
    @organisation = FactoryBot.create(:organisation)
    @services = FactoryBot.create_list(:service_with_all_associations, 3, organisation: @organisation)
    @service_for_deletion = @services.last
    @service_for_deletion.update(discarded_at: Time.now - 40.days, marked_for_deletion: Time.now - 31.days)
    @service_for_deletion.reload
  end

  it "deletes services and associations" do
    send_need_1 = @service_for_deletion.send_needs.first
    send_need_2 = @service_for_deletion.send_needs.last

    send_need_1_service_count = send_need_1.services.count
    send_need_2_service_count = send_need_2.services.count

    service_at_location = @service_for_deletion.service_at_locations.first
    service_link = @service_for_deletion.links.last
    service_meta = @service_for_deletion.meta.first
    service_cost_option = @service_for_deletion.cost_options.last
    service_reg_sched = @service_for_deletion.regular_schedules.first
    service_contact = @service_for_deletion.contacts.first
    service_feedback = @service_for_deletion.feedbacks.first
    service_taxonomy = @service_for_deletion.service_taxonomies.first
    service_watch = @service_for_deletion.watches.first
    service_note = @service_for_deletion.notes.first
    service_local_offer = @service_for_deletion.local_offer

    Rake::Task["process_permanent_deletions"].invoke
    expect { @service_for_deletion.reload }.to raise_error ActiveRecord::RecordNotFound
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
end
