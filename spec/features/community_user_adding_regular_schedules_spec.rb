require 'rails_helper'

feature 'Community user managing regular schedules', type: :feature do

  before do
    user = FactoryBot.create :user
    login_as user
    visit root_path
  end


  context 'With no existing schedules or locations' do

    # scenario 'I can add a service with opening times at all locations to the directory', js: true do
    #   click_link_or_button('Add Service, Event or Activity')

    #   fill_in('What is your service or activity called?', with: 'Example service')
    #   fill_in('Describe your service', with: 'Example description here')
    #   click_link_or_button('Continue')


    #   expect(page).to have_content("List a new service")
    #   expect(page).to have_content("Submission incomplete")
    #   expect(page).to have_content("You've completed 1 of 10 sections.")
    #   expect(page).to have_content("Opening and event times")


    #   # need to complete all sections in order to save

    #   click_link_or_button('Website and social media')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Visibility')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Locations')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Fees')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Contacts')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Ages')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Special educational needs and disabilities')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Suitable for')
    #   click_link_or_button('Continue')

    #   # now we can do the opening times

    #   click_link_or_button('Opening and event times')
    #   click_link_or_button 'Add a schedule'


    #   select 'Monday', from: 'weekday'
    #   fill_in('opens_at', with: '09:00')
    #   fill_in('closes_at', with: '17:00')

    #   click_link_or_button('Continue')

    #   expect(page).to have_content("Ready to submit")
    #   click_link_or_button('Finish and send')
    #   expect(page).to have_content("Your service has been successfully submitted")
    
    #   click_link_or_button('Return to dashboard')
    
    #   expect(page).to have_content("Example service")
    #   expect(page).to have_content("Pending")
      
    # end

    # scenario 'I can add a service with event time at all locations to the directory', js: true do
    #   click_link_or_button('Add Service, Event or Activity')

    #   fill_in('What is your service or activity called?', with: 'Example service')
    #   fill_in('Describe your service', with: 'Example description here')
    #   click_link_or_button('Continue')


    #   expect(page).to have_content("List a new service")
    #   expect(page).to have_content("Submission incomplete")
    #   expect(page).to have_content("You've completed 1 of 10 sections.")
    #   expect(page).to have_content("Opening and event times")


    #   # need to complete all sections in order to save

    #   click_link_or_button('Website and social media')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Visibility')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Locations')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Fees')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Contacts')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Ages')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Special educational needs and disabilities')
    #   click_link_or_button('Continue')
    #   click_link_or_button('Suitable for')
    #   click_link_or_button('Continue')

    #   # now we can do the opening times

    #   click_link_or_button('Opening and event times')
    #   click_link_or_button 'Add a schedule'


    #   select 'Event time', from: 'time_type'

    #   fill_in('dtstart', with: '01/01/2024')
    #   fill_in('event_opens_at', with: '09:00')
    #   fill_in('event_closes_at', with: '17:00')

    #   click_link_or_button('Continue')

    #   expect(page).to have_content("Ready to submit")
    #   click_link_or_button('Finish and send')
    #   expect(page).to have_content("Your service has been successfully submitted")
    
    #   click_link_or_button('Return to dashboard')
    
    #   expect(page).to have_content("Example service")
    #   expect(page).to have_content("Pending")
      
    # end

  end
end
