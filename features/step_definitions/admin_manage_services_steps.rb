When("I click the add service button") do
    click_link_or_button('Add service')
end

Then("I should see the new service form") do
    expect(page).to have_content("Add a new service")
end

Given("I am on the add new service page") do
    visit new_admin_service_path
end

When("I fill in the name with {string}") do |service_name|
    fill_in('Name', with: service_name)
end

When("I select the organisation {string}") do |org_name|
    find('.choices').click
    find('.choices__item', text: org_name).click
end

When("I fill in the suitability field with {string}") do |suit_name|
    find('.checkbox__label', text: suit_name, visible: false).click
end

When("I submit the service") do
    click_link_or_button('Create')
end

When("I update the service") do
    click_link_or_button('Update')
end

Then("The service should be created") do
    expect(page).to have_content("Service has been created")
end

Then("The service should be updated") do
    expect(page).to have_content("Service has been updated")
end

Then("The service {string} should have two suitabilities") do |service_name|
    expect(Service.where(name: service_name).first.suitabilities.count).to eq(2)
end