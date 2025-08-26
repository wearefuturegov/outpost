# https://github.com/heartcombo/devise/wiki/How-To:-Test-with-Capybara
RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :feature
  # config.include Devise::Test::ControllerHelpers, type: :controller
  # config.include Devise::Test::ControllerHelpers, type: :view
end