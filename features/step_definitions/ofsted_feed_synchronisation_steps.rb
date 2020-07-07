Given('a service exists with a corresponding Ofsted feed item') do
  @ofsted_data = JSON.load File.open "features/support/data/ofsted_response_1.json"
  @organisation = Organisation.create({})
  @ofsted_item = OfstedItem.create!(reference_number: 123456)
  @service = Service.create!({ organisation: @organisation, name: 'Test Service' })
end

And('the feed item has changed') do
  @ofsted_data[0]['provider_name'] = 'Changed name'
  mock_ofsted_response(@ofsted_data)
end

When('outpost is synchronised with the Ofsted feed') do
  require "rake"
  @rake = Rake::Application.new
  Rake.application = @rake
  Rake.application.rake_require "tasks/ofsted"
  Rake::Task.define_task(:environment)
  Rake.application.invoke_task('ofsted:update_items')
end

Then('the Ofsted item should be flagged for review') do
  ofsted_items = OfstedItem.all
  expect(ofsted_items.length).to eq(1)
  expect(ofsted_items[0].provider_name).to eq 'Changed name'
  expect(ofsted_items[0].status).to eq 'changed'
end

def mock_ofsted_response(hash)
  WebMock.stub_request(:get, /bucks-ofsted-feed.herokuapp.com\/.*/)
      .to_return(body: hash.to_json, headers: { 'Content-Type': 'application/json' })
end