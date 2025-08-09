Capybara.javascript_driver = :selenium_chrome_headless

# Uncomment this if you want to run tests against a remote Selenium server
# Capybara.register_driver :remote_chrome do |app|
#   options = Selenium::WebDriver::Chrome::Options.new
#   options.add_argument('--no-sandbox')
#   options.add_argument('--disable-dev-shm-usage')
#   options.add_argument('--window-size=1400,1400')
#   options.add_argument('--disable-gpu')
#   options.add_argument('--headless=new') # Remove if you want a visible browser
#   options.add_argument('--enable-logging')
#   options.add_argument('--v=1')

#   Capybara::Selenium::Driver.new(
#     app,
#     browser: :remote,
#     url: 'http://selenium:4444/wd/hub',
#     capabilities: options,
#   )
# end

# Capybara.server_host = '0.0.0.0'
# Capybara.server_port = 3000
# Capybara.app_host = 'http://outpost:3000'
# Capybara.javascript_driver = :remote_chrome
