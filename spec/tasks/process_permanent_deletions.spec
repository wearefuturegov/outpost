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

  it "deletes services" do
    send_need_1 = @service_for_deletion.send_needs.first
    send_need_2 = @service_for_deletion.send_needs.last

    send_need_1_service_count = send_need_1.services.count
    send_need_2_service_count = send_need_2.services.count

    Rake::Task["process_permanent_deletions"].invoke
    expect { @service_for_deletion.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(send_need_1.services.count).to eq(send_need_1_service_count - 1)
    expect(send_need_2.services.count).to eq(send_need_1_service_count - 1)
  end
end