require "rails_helper"
Rails.application.load_tasks

describe "process permanent deletions" do

  after(:each) do
    Rake::Task["process_permanent_deletions"].reenable
  end

  context 'deleting services' do
    let(:service_for_deletion) { FactoryBot.create(:service, discarded_at: Time.now - 40.days, marked_for_deletion: Time.now - 31.days) }
    let!(:service_at_location) { FactoryBot.create :service_at_location, service: service_for_deletion }
    let!(:link) { FactoryBot.create :link, service: service_for_deletion }
    let!(:send_needs) { FactoryBot.create_list(:send_need, 3, services: [service_for_deletion]) }
    let!(:service_meta) { FactoryBot.create(:service_meta, service: service_for_deletion) }
    let!(:cost_option) { FactoryBot.create(:cost_option, service: service_for_deletion) }
    let!(:regular_schedule) { FactoryBot.create(:regular_schedule, service: service_for_deletion) }
    let!(:contact) { FactoryBot.create(:contact, service: service_for_deletion) }
    let!(:feedback) { FactoryBot.create(:feedback, service: service_for_deletion) }
    let!(:service_taxonomy) { FactoryBot.create(:service_taxonomy, service: service_for_deletion) }
    let!(:watch) { FactoryBot.create(:watch, service: service_for_deletion) }
    let!(:note) { FactoryBot.create(:note, service: service_for_deletion) }
    let!(:local_offer) { FactoryBot.create(:local_offer, service: service_for_deletion) }

    it "deletes services and associations" do
      expect(Service.all.count).to eq(1)

      Rake::Task["process_permanent_deletions"].invoke

      expect { service_for_deletion.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { service_at_location.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { link.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { service_meta.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { cost_option.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { regular_schedule.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { contact.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { feedback.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { service_taxonomy.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { watch.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { note.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { local_offer.reload }.to raise_error ActiveRecord::RecordNotFound

      expect(Service.all.count).to eq(0)

      expect(send_needs.first.services.count).to eq(0)
      expect(send_needs.second.services.count).to eq(0)
    end
  end

  describe 'deleting users that have created notes' do
    let!(:users_for_deletion) { FactoryBot.create_list(:user, 3, discarded_at: Time.now - 40.days, marked_for_deletion: Time.now - 31.days) }
    let(:note) { FactoryBot.create :note }
    let(:user_with_note) { note.user }

    before do
      user_with_note.update(discarded_at: Time.now - 40.days, marked_for_deletion: Time.now - 31.days)
    end

    it 'deletes the users and does not error' do
      users_count = User.all.count
      Rake::Task["process_permanent_deletions"].invoke
      # Only 3 should be deleted until we decide what to do with deleted users
      # with notes
      expect(User.all.count).to eq(users_count - 3)
    end
  end
end
