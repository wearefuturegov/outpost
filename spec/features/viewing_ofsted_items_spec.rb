require 'rails_helper'

feature 'Viewing Ofsted feed items', type: :feature do
  let!(:new_ofsted_item) { FactoryBot.create :ofsted_item, :new }
  let!(:changed_ofsted_item) { FactoryBot.create :ofsted_item, :changed }
  let!(:removed_ofsted_item) { FactoryBot.create :ofsted_item, :deleted }

  it 'is not viewable by community users' do
    community_user = FactoryBot.create :user
    login_as community_user
    visit pending_admin_ofsted_index_path
    expect(page).to have_content 'Your services'
    expect(page).to_not have_content 'Ofsted'
  end

  context 'as an Ofsted viewer admin' do
    before do
      admin_user = FactoryBot.create :user, :ofsted_viewer
      login_as admin_user
      visit pending_admin_ofsted_index_path
    end

    scenario 'I can see pending Ofsted items with their status' do
      expect(page).to have_content 'Ofsted feed'
      expect(page).to have_content 'Pending (3)'
      expect(page).to have_content new_ofsted_item.setting_name.truncate(25)
      expect(page).to have_content changed_ofsted_item.setting_name.truncate(25)
      expect(page).to have_content removed_ofsted_item.setting_name.truncate(25)

      click_link new_ofsted_item.setting_name.truncate(25)
      expect(page).to have_content 'This is a new provider'
      click_link 'Ofsted feed'
      click_link 'Pending'

      click_link changed_ofsted_item.setting_name.truncate(25)
      expect(page).to have_content 'Ofsted has made changes'
      click_link 'Ofsted feed'
      click_link 'Pending'

      click_link removed_ofsted_item.setting_name.truncate(25)
      expect(page).to have_content 'This item is no longer present in the Ofsted feed'
    end
  end
end
