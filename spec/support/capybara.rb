# NB you can view capybara's chrome driver options here https://github.com/teamcapybara/capybara/blob/b3325b198464b806f07ec2011ceb532d6d5cf4ab/lib/capybara/registrations/drivers.rb#L31
# uncomment to enable webdriver debugging
# logger = Selenium::WebDriver.logger
# logger.level = :debug

# register a remote chrome driver for those times where chrome just wont behave (.github/workflows/test-in-herokuish.yml)
Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')
  options.add_argument('--disable-gpu')
  options.add_argument('--headless=new') # Remove if you want a visible browser
  options.add_argument('--enable-logging')
  options.add_argument('--v=1')

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: 'http://selenium:4444/wd/hub',
    capabilities: options,
  )
end

# use remote chrome driver if REMOTE_CHROME=true otherwise use selenium_chrome_headless from selenium_webdrivers gem
if ENV['REMOTE_CHROME'] && ENV['REMOTE_CHROME'] != '' && ENV['REMOTE_CHROME'] != 'false'
  Capybara.server_host = '0.0.0.0'
  Capybara.server_port = 3001
  Capybara.app_host = 'http://outpost:3001'
  Capybara.javascript_driver = :remote_chrome
else
  Capybara.javascript_driver = :selenium_chrome_headless
end