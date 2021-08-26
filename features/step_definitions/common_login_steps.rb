Given(/I am logged in as (.*) user/) do |type|
  if type == 'a superadmin'
    @login_user = FactoryBot.create(:user, :superadmin)
  elsif type == 'an ofsted admin'
    @login_user = FactoryBot.create(:user, :ofsted_viewer)
  elsif type == 'an admin'
    @login_user = FactoryBot.create(:user, :services_admin)
  elsif type == 'a user manager admin'
    @login_user = FactoryBot.create(:user, :user_manager)
  else
    @login_user = FactoryBot.create(:user)
  end
  @login_user.save!
  login
end

def login
  visit('/')
  email_input = find('#user_email')
  email_input.click
  email_input.send_keys(@login_user.email)

  password_input = find('#user_password')
  password_input.click
  password_input.send_keys(@login_user.password)
  click_button('Sign in')

  if page.has_css?('.introjs-button.introjs-skipbutton', wait: 1)
    tutorial_popup = find('.introjs-button.introjs-skipbutton')
    tutorial_popup.click
  end
  sleep(1)
end
