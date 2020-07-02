Given('I am logged in as a user') do
  @organisation = Organisation.create(name: 'Test Organisation')
  @login_user = User.create(first_name: 'User', last_name: 'Test', password: 'Password1', email: 'user@emailaddress.com', organisation: @organisation)
  @login_user.save!
  visit('/')
  email_input = find('#user_email')
  email_input.click
  email_input.send_keys('user@emailaddress.com')

  password_input = find('#user_password')
  password_input.click
  password_input.send_keys('Password1')
  click_button('Log in')

  tutorial_popup = find('.introjs-button.introjs-skipbutton')
  tutorial_popup.click
  sleep(1)
end