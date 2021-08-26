Given 'there is a community user called {string}' do |name|
  names = name.split
  FactoryBot.create(:user, first_name: names.first, last_name: names.last)
end

Then("I should see an unchecked field for {string}") do |string|
  expect(page).to have_field(string, visible: false, checked: false)
end

Then("I should not see {string}") do |string|
  expect(page).to_not have_content(string)
end
