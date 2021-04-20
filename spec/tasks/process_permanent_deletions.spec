require "rails_helper"
Rails.application.load_tasks

describe "process permanent deletions" do

  before do
    @organisation = FactoryBot.create(:organisation)
    @services = FactoryBot.create_list(:service_with_all_associations, 3, organisation: @organisation)
    @service_for_deletion = @services.last
    @service_for_deletion.update(discarded_at: Time.now - 40.days, marked_for_deletion: Time.now - 31.days)
  end

  it "deletes services" do
    Rake::Task["process_permanent_deletions"].invoke
    expect { @service_for_deletion.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end