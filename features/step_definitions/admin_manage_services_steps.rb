When("I click the add service button") do
    click_link_or_button('Add service')
end

Then("I should see the new service form") do
    expect(page).to have_content("Add a new service")
end

Given("I am on the add new service page") do
    visit new_admin_service_path
end

When("I fill in the name") do
    fill_in('Name', with: 'Test service')
end

When("I select the organisation {string}") do |org_name|
    find('.choices').click
    find('.choices__item', text: org_name).click
end

When("I fill in the suitability field") do
    find('.checkbox__label', text: 'Autism', visible: false).click
end

When("I submit the service") do
    click_link_or_button('Create')
end

Then("The service should be created") do
    expect(page).to have_content("Service has been created")
end
