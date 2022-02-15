require 'rails_helper'

feature 'Managing users', type: :feature do
  let!(:community_user) { FactoryBot.create :user }
  let!(:deactivated_user) { FactoryBot.create :user, :deactivated }

  scenario 'I must have the correct privileges' do
    login_as community_user
    visit admin_users_path
    expect(page).to have_content 'Your services'
    expect(page).to_not have_content 'Manage Ofsted'
  end

  context 'as a superadmin' do
    before do
      admin_user = FactoryBot.create :user, :superadmin
      login_as admin_user
    end

    scenario 'I can see all users' do
      visit admin_users_path
      expect(page).to have_content('All (3)')
      expect(page).to have_content('Active (2)')
      expect(page).to have_content('Deactivated (1)')
      expect(page).to have_content community_user.display_name
      expect(page).to have_content deactivated_user.display_name

      expect(page.find_link('All').find(:xpath, '..')[:class]).to include('current');  
      expect(page.find_link('Active').find(:xpath, '..')[:class]).to_not include('current');
      expect(page.find_link('Deactivated').find(:xpath, '..')[:class]).to_not include('current');
    end

    scenario 'I can filter by active users' do
      visit admin_users_path
      click_link 'Active'
      expect(page).to have_content community_user.display_name
      expect(page).to_not have_content deactivated_user.display_name

      expect(page.find_link('All').find(:xpath, '..')[:class]).to include('current');  
      expect(page.find_link('Active').find(:xpath, '..')[:class]).to include('current');
      expect(page.find_link('Deactivated').find(:xpath, '..')[:class]).to_not include('current');
    end

    scenario 'I can filter by deactivated users' do
      visit admin_users_path
      click_link 'Deactivated'
      expect(page).to_not have_content community_user.display_name
      expect(page).to have_content deactivated_user.display_name

      expect(page.find_link('All').find(:xpath, '..')[:class]).to include('current');  
      expect(page.find_link('Active').find(:xpath, '..')[:class]).to_not include('current');
      expect(page.find_link('Deactivated').find(:xpath, '..')[:class]).to include('current');
    end



    scenario 'I can see details for a user' do
      visit admin_users_path
      click_link community_user.display_name
      expect(page).to have_field('User can manage services', visible: false, checked: false)
      expect(page).to have_field('User can see Ofsted feed', visible: false, checked: false)
      expect(page).to have_field('User can manage other users, taxonomies and custom fields', visible: false, checked: false)
    end
  end

  context 'as a user manager' do
    before do
      admin_user = FactoryBot.create :user, :user_manager
      login_as admin_user
    end

    scenario 'I can see details for a user' do
      visit admin_users_path
      click_link community_user.display_name
      expect(page).to have_field('User can manage services', visible: false, checked: false)
      expect(page).to_not have_content 'User can see Ofsted feed'
      expect(page).to have_field('User can manage other users, taxonomies and custom fields', visible: false, checked: false)
    end
  end


end
