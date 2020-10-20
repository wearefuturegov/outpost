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