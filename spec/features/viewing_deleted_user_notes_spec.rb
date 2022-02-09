require 'rails_helper'
require 'rake'
Rails.application.load_tasks

feature 'Viewing deleted user notes and versions' do
  let(:admin_to_be_deleted) { FactoryBot.create :user, :services_admin, discarded_at: DateTime.now - 40.days, marked_for_deletion: DateTime.now - 40.days }
  let!(:service) { FactoryBot.create :service }
  let!(:note) { FactoryBot.create :note, user: admin_to_be_deleted, service: service }
  let!(:version) { FactoryBot.create :service_version, item_type: 'Service', item_id: service.id, whodunnit: admin_to_be_deleted.id.to_s, event: 'update' }

  before do
    admin = FactoryBot.create :user, :services_admin

    login_as admin 
  end

  context 'on the service show page' do
    before do
      visit admin_service_path service
    end

    it 'shows the deleted user name with the notes and versions' do
      within '#service-history' do
        expect(page).to have_link(admin_to_be_deleted.display_name)
      end

      within '#service-notes' do
        expect(page).to have_link(admin_to_be_deleted.display_name)
        expect(page).to have_content(note.body)
      end

      Rake.application.invoke_task 'process_permanent_deletions'

      page.refresh

      within '#service-history' do
        expect(page).to_not have_link(admin_to_be_deleted.display_name)
        expect(page).to have_content(admin_to_be_deleted.display_name)
      end

      within '#service-notes' do
        expect(page).to_not have_link(admin_to_be_deleted.display_name)
        expect(page).to have_content(admin_to_be_deleted.display_name)
        expect(page).to have_content(note.body)
      end
    end
  end

  context 'on the version history page' do
    before do
      visit admin_service_path service
      click_link 'Compare versions'
    end

    it 'shows the deleted user name' do
      expect(page).to have_content(admin_to_be_deleted.display_name)
    end
  end
end
