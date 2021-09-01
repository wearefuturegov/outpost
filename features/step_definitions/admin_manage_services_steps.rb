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

When("I select the organisation") do
    find('#service_organisation_id', visible: :all).find(:xpath, "../../div[contains(@id, 'choices--service_organisation_id-item-choice-1')]").select_option
    #find('#service_organisation_id', visible: :all).find(:option, 'Test org').select_option
    #select('Test org', :from => '.choices__list')
end

When("I fill in the suitability field") do
    click_link_or_button("Suitable for")
    check("Autism")
end

When("I submit the service") do
    click_link_or_button('Create')
end

Then("The service should be created") do
    expect(page).to have_content("Service created")
end