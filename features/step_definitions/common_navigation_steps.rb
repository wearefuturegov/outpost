Given('I am on the dashboard page') do
  visit('/')
end

Given('I am on the new service creation page') do
  step('I am on the dashboard page')
  step('I choose to add a new service')
end

Given('I am on the admin services page') do
  visit('/admin/services')
end

Given('I am on the admin users page') do
  visit('/admin/users')
end

Given(/I visit the user page for (.*)/) do |name_or_email|
  visit admin_users_path
  click_link name_or_email
end

Given('I visit the edit service page for {string}') do |service_name|
  click_link 'Services'
  click_link service_name
end
