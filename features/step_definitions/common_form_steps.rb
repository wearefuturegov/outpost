Then("I should see an unchecked field for {string}") do |string|
  expect(page).to have_field(string, visible: false, checked: false)
end

Then("I should see an unchecked field for {string} that is disabled") do |string|
  expect(page).to have_field(string, visible: false, checked: false, disabled: true)
end
