ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'spec_helper'
require 'rspec/rails'
require 'devise'
require 'selenium/webdriver'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }


# Setup chrome headless driver
# heroku buildpacks gives us GOOGLE_CHROME_BIN
binary = ENV.fetch("GOOGLE_CHROME_BIN", nil)
# "/usr/bin/chromium-browser"
# puts binary
# uncomment to enable webdriver debugging
# logger = Selenium::WebDriver.logger
# logger.level = :debug

Selenium::WebDriver::Chrome.path = binary if binary

# Register headless chrome for JS tests
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--disable-extensions")
  options.add_argument("--disable-gpu")
  options.add_argument("--headless")
  options.add_argument("--window-size=1400,1400")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--remote-debugging-port=9222")
  options.add_argument("--remote-debugging-pipe")
  options.add_argument("--whitelisted-ips")
  options.add_argument("--disable-gpu-compositing")
  options.add_argument("--disable-gpu-compositing") 
  options.add_argument("--disable-setuid-sandbox") 
  options.add_argument("--single-process")

  options.binary = binary

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    options: options,
    service: Selenium::WebDriver::Chrome::Service.chrome(log: :stderr, args: ["--whitelisted-ips=", "--allowed-ips=", "--disable-dev-shm-usage"])
end
# switch to this to enable chrome debugging
# service: Selenium::WebDriver::Chrome::Service.chrome(log: :stderr, args: ["--whitelisted-ips=", "--allowed-ips=", "--disable-dev-shm-usage", "--log-level=DEBUG"])

# leaving this in case you want to run the tests with a host or remote browser
# Capybara.server_port = 8200
# Capybara.server_host = "0.0.0.0"
# Capybara.app_host = "http://outpost:#{Capybara.server_port}"

# you may instead want to consider leaving the faster :rack_test as the default_driver, 
# and marking only those tests that require a JavaScript-capable driver using js: true or @javascript, respectively. 
# By default, JavaScript tests are run using the :selenium driver. You can change this by setting Capybara.javascript_driver.
Capybara.javascript_driver = :headless_chrome


# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Configure Devise
  config.include Devise::Test::IntegrationHelpers, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
