When('I choose to add a new service') do
  click_link_or_button('Add service')
end

Then('I should see the new service creation page') do
  check_page_title('Add a new service')
end

And('I have entered valid service details for all pages') do
  click_fill_in('#service_name', 'Test service')
  click_fill_in('#service_description', 'Test service description')
  find('label[for=service_free_true]').click
  find('label[for=service_needs_referral_false]').click
  click_link_or_button('Continue')

  check_page_title('How can people access your service?')
  click_link_or_button('Continue')

  check_page_title('Help people find your service')
  click_link_or_button('Continue')
end

When('I submit the service') do
  click_link_or_button('Finish and send')
end

Then('I should see that my service is awaiting approval') do
  expect(page).to have_content('Your service has been successfully submitted')
end

def check_page_title(text)
  expect(page).to have_content(text)
end