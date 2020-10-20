Given("I'm registered") do
    @org = Organisation.create(name: "Test org")
    @user = User.create(
        first_name: "First",
        last_name: "Name",
        email: "test@email.com",
        password: "Password1",
        organisation: @org
    )
end

And("I'm at the root") do
    visit root_path
end

Then("I should be able to sign in") do
    fill_in('Email', with: 'test@email.com')
    fill_in('Password', with: 'Password1')
    click_link_or_button('Log in')
end

Then("I should see the dashboard") do
    expect(page).to have_content("Your services")
    expect(page).to have_content("Your users")
end

When("I add a new service") do
    click_link_or_button('Add service')
end

Then("I can fill in fields for name and description") do
    fill_in('What is your service or activity called?', with: 'Example service')
    fill_in('Describe your service', with: 'Example description here')
    click_link_or_button('Continue')
end

Then("I should reach the task list") do
    expect(page).to have_content("List a new service")
    expect(page).to have_content("Submission incomplete")
end

Given("I can fill in website and social media fields") do
    click_link_or_button('Website and social media')
    fill_in('Website', with: 'http://example.com')
    click_link_or_button('Continue')
end

Given("I can fill in visibility dates") do
    click_link_or_button('Visibility')
    uncheck("Make this service publicly visible")
    check("Make this service publicly visible")
    fill_in('From', with: '01/01/2020')
    fill_in('To', with: '01/01/2021')
    click_link_or_button('Continue')
end

Given("I can choose categories") do
    # @taxonomy = Taxonomy.create(name: "Test category")
    click_link_or_button('Categories')
    # check("Test category")
    # ...
    click_link_or_button('Continue')
end

Given("I can create schedules") do
    click_link_or_button('Scheduling')
    # .....
    click_link_or_button('Continue')
end

Given("I can create fees") do
    click_link_or_button('Fees')
    # ....
    click_link_or_button('Continue')
end

Given("I can create locations") do
    click_link_or_button('Locations')
    # ....
    click_link_or_button('Continue')
end

Given("I can create contacts") do
    click_link_or_button('Contacts')
    # ....
    click_link_or_button('Continue')
end

Given("I can set ages") do
    click_link_or_button('Ages')
    fill_in('Minimum', with: '5')
    fill_in('Maximum', with: '10')
    click_link_or_button('Continue')
end

Given("I can answer local offer questions") do
    click_link_or_button('Special educational needs and disabilities')
    check("This service is part of the local offer")
    uncheck("This service is part of the local offer")
    # ...
    click_link_or_button('Continue')
end

Given("I can answer extra questions") do
    click_link_or_button('Extra questions')
    # ...
    click_link_or_button('Continue')
end

Then("I can submit my service") do
    expect(page).to have_content("Ready to submit")
    click_link_or_button('Finish and send')
    expect(page).to have_content("Your service has been successfully submitted")
end

And("I see it pending on the dashboard") do
    click_link_or_button('Return to dashboard')
    expect(page).to have_content("Example service")
    expect(page).to have_content("Pending")
end