require 'rails_helper'

feature 'Editing site settings' do

  context 'as a regular admin' do
    let(:admin) { FactoryBot.create :user, :services_admin }

    before { login_as admin }

    it 'cannot view or update site settings' do
      visit edit_admin_settings_path
      expect(page).to_not have_current_path edit_admin_settings_path
      expect(page).to_not have_content 'Outpost title'
    end
  end

  context 'as a super admin' do
    let(:admin) { FactoryBot.create :user, :superadmin }

    before { login_as admin }

    it 'can view site settings' do
      visit edit_admin_settings_path
      expect(page).to have_current_path edit_admin_settings_path
      expect(page).to have_content 'Outpost title'
    end

    it 'can edit site settings' do
      site_name = 'My service directory'
      visit edit_admin_settings_path
      fill_in :form_admin_settings_outpost_title, with: site_name
      click_button 'Save'
      expect(page).to have_content 'Settings have been saved'
      visit root_path
      expect(page).to have_content site_name
    end
  end
end
