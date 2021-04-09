When("I click the add service button") do
    click_link_or_button('Add service')
end

Then("I should see the new service form") do
    expect(page).to have_content("Add a new service")
end