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
