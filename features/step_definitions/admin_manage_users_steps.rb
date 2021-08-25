Given 'I visit the active users link' do
  click_link 'Active'
end

And 'I visit the deactivated users link' do
  click_link 'Deactivated'
end

And 'there is an active user' do
  @active_user = FactoryBot.create :user
end

And 'there is a deactivated user' do
  @deactivated_user = FactoryBot.create :user, :deactivated
end

Then 'I should see all the users' do
  # There are 3 in total because there's also the logged in admin
  expect(page).to have_content('All (3)')
  expect(page).to have_content('Active (2)')
  expect(page).to have_content('Deactivated (1)')
  expect(page).to have_content @active_user.display_name
  expect(page).to have_content @deactivated_user.display_name
end

And 'I should see only the deactivated user' do
  expect(page).to_not have_content @active_user.display_name
  expect(page).to have_content @deactivated_user.display_name
end

And 'I should see only the active users' do
  expect(page).to have_content @active_user.display_name
  expect(page).to_not have_content @deactivated_user.display_name
end

And 'the active users link should be disabled' do
  expect(page).to have_link 'All'
  expect(page).to_not have_link 'Active'
  expect(page).to have_link 'Deactivated'
end

And 'the deactivated users link should be disabled' do
  expect(page).to have_link 'All'
  expect(page).to have_link 'Active'
  expect(page).to_not have_link 'Deactivated'
end
