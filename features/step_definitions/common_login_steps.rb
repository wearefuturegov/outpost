Given(/I am logged in as (.*)user/) do |type|
  @organisation = Organisation.create(name: 'Test Organisation')
  if type == 'an ofsted admin '
    @login_user = User.create(first_name: 'User', last_name: 'Test', password: 'Password1', email: 'user@emailaddress.com', organisation: @organisation, admin: true, admin_ofsted: true)
  else
    @login_user = User.create(first_name: 'User', last_name: 'Test', password: 'Password1', email: 'user@emailaddress.com', organisation: @organisation)
  end
  @login_user.save!
  login
end

def login
  visit('/')
  email_input = find('#user_email')
  email_input.click
  email_input.send_keys('user@emailaddress.com')

  password_input = find('#user_password')
  password_input.click
  password_input.send_keys('Password1')
  click_button('Sign in')

  if page.has_css?('.introjs-button.introjs-skipbutton', wait: 1)
    tutorial_popup = find('.introjs-button.introjs-skipbutton')
    tutorial_popup.click
  end
  sleep(1)
end