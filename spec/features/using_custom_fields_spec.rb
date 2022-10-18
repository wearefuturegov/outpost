require 'rails_helper'

feature 'Using custom fields', type: :feature do
  context 'as a user manager' do
    let!(:service) { FactoryBot.create :service }
    let!(:custom_field_section) { FactoryBot.create :custom_field_section }
    let(:date) { Date.today }

    before do
      admin_user = FactoryBot.create :user, :user_manager
      login_as admin_user
      visit root_path
    end

    scenario 'I can create and use custom fields for services', js: true do
      click_link 'Services'
      click_link 'Custom fields'
      click_link custom_field_section.name
      click_link 'Add a field'
      fill_in('Label', with: 'Custom date')
      select 'Date', from: 'Field type'
      click_link_or_button 'Update'
      expect(page).to have_content 'Fields have been updated'

      visit admin_services_path
      click_link service.name
      fill_in 'Custom date', with: date
      expect(page).to have_field('Custom date', type: 'date', with: date)
    end
  end

end
