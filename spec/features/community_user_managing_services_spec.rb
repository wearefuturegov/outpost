require 'rails_helper'

feature 'Community user managing services', type: :feature do
  let!(:suitabilities) { FactoryBot.create_list :suitability, 5 }
  let!(:taxonomies) { FactoryBot.create_list :taxonomy, 5 }

  before do
    user = FactoryBot.create :user
    login_as user
    visit root_path
  end

  scenario 'I can see the dashboard' do
    expect(page).to have_content("Your services")
    expect(page).to have_content("Your users")
  end

  scenario 'I can add a service to the directory' do
    click_link_or_button('Add service')

    fill_in('What is your service or activity called?', with: 'Example service')
    fill_in('Describe your service', with: 'Example description here')
    click_link_or_button('Continue')

    expect(page).to have_content("List a new service")
    expect(page).to have_content("Submission incomplete")

    click_link_or_button('Website and social media')
    fill_in('Website', with: 'http://example.com')
    click_link_or_button('Continue')

    click_link_or_button('Visibility')
    uncheck("Make this service publicly visible")
    check("Make this service publicly visible")
    fill_in('From', with: '01/01/2020')
    fill_in('To', with: '01/01/2021')
    click_link_or_button('Continue')

    click_link_or_button('Opening times')
    click_link_or_button('Continue')

    click_link_or_button('Fees')
    click_link_or_button('Continue')

    click_link_or_button('Locations')
    click_link_or_button('Continue')

    click_link_or_button('Contacts')
    click_link_or_button('Continue')

    click_link_or_button('Ages')
    fill_in('Minimum', with: '5')
    fill_in('Maximum', with: '10')
    click_link_or_button('Continue')

    click_link_or_button('Special educational needs and disabilities')
    check("This service is part of the local offer")
    uncheck("This service is part of the local offer")
    click_link_or_button('Continue')

    click_link_or_button('Suitable for')
    check suitabilities.first.name
    click_link_or_button('Continue')

    click_link_or_button('Extra questions')
    click_link_or_button('Continue')

    expect(page).to have_content("Ready to submit")
    click_link_or_button('Finish and send')
    expect(page).to have_content("Your service has been successfully submitted")

    click_link_or_button('Return to dashboard')
    expect(page).to have_content("Example service")
    expect(page).to have_content("Pending")
  end
end
