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
      visit admin_users_path
    end

    scenario 'I can see all users' do
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
      click_link 'Active'
      expect(page).to have_content community_user.display_name
      expect(page).to_not have_content deactivated_user.display_name

      expect(page.find_link('All').find(:xpath, '..')[:class]).to include('current');  
      expect(page.find_link('Active').find(:xpath, '..')[:class]).to include('current');
      expect(page.find_link('Deactivated').find(:xpath, '..')[:class]).to_not include('current');
    end

    scenario 'I can filter by deactivated users' do
      click_link 'Deactivated'
      expect(page).to_not have_content community_user.display_name
      expect(page).to have_content deactivated_user.display_name

      expect(page.find_link('All').find(:xpath, '..')[:class]).to include('current');  
      expect(page.find_link('Active').find(:xpath, '..')[:class]).to_not include('current');
      expect(page.find_link('Deactivated').find(:xpath, '..')[:class]).to include('current');
    end



    scenario 'I can see details for a user' do
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
      visit admin_users_path
    end

    scenario 'I can see details for a user' do
      click_link community_user.display_name
      expect(page).to have_field('User can manage services', visible: false, checked: false)
      expect(page).to_not have_content 'User can see Ofsted feed'
      expect(page).to have_field('User can manage other users, taxonomies and custom fields', visible: false, checked: false)
    end

    scenario 'I can deactivate a user' do
      expect(page).to have_content('Deactivated (1)')
      click_link community_user.display_name
      click_link 'Deactivate'
      expect(page).to have_content 'That user has been deactivated'
      expect(page).to have_content('Active (1)')
      expect(page).to have_content('Deactivated (2)')
    end

    scenario 'I can mark a deactivated user for deletion' do
      click_link 'Deactivated'
      click_link deactivated_user.display_name
      check 'user_marked_for_deletion'
      click_button 'Update'
      expect(page).to have_content 'User has been updated'
      expect(page).to have_field('user_marked_for_deletion', checked: true)
      click_link 'Back to users'
      expect(page).to have_content 'Marked for deletion on'
    end
  end


end
