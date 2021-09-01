Given 'there is a community user called {string}' do |name|
  names = name.split
  FactoryBot.create(:user, first_name: names.first, last_name: names.last)
end

Given 'there is a service called {string}' do |name|
  FactoryBot.create(:service, name: name)
end

Then("I should see an unchecked field for {string}") do |string|
  expect(page).to have_field(string, visible: false, checked: false)
end

Then("I should not see {string}") do |string|
  expect(page).to_not have_content(string)
end

Then 'I can see a {string} type field called {string}' do |type, label|
  expect(page).to have_field(label, type: type)
end

Then 'I can see a {string} type field called {string} with a value of {string}' do |type, label, value|
  expect(page).to have_field(label, type: type, with: value)
end

Then("I can fill in the {string} field with {string}") do |label, value|
  fill_in label, with: value
end

Given("An organisation exists") do
  @organisation = FactoryBot.create(:organisation, name: "Test org")
end

Given("A service exists") do
  @organisation = FactoryBot.create(:service, name: "Test service", suitabilities: [Suitability.where(name: 'Autism').first])
end

Given("I am on the admin service page for {string}") do |service_name|
  visit admin_service_path(Service.where(name: service_name).first)
end

Given("Some options for suitability exist") do
  FactoryBot.create(:suitability, name: 'Autism')
  FactoryBot.create(:suitability, name: 'Learning difficulties')
end
