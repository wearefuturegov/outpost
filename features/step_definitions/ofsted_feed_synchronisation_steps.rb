require 'rake'
rake = Rake::Application.new
Rake.application = rake
Rake.application.rake_require "tasks/ofsted"
Rake::Task.define_task(:environment)

Given('a service exists with a corresponding Ofsted feed item') do
  OfstedItem.delete_all
  mock_ofsted_response JSON.load File.open "features/support/data/ofsted_response_start.json"

  rake.tasks.each {|t| t.reenable }
  rake.invoke_task('ofsted:create_initial_items')

  @ofsted_item = OfstedItem.where(reference_number: 123456).first
end

And('the feed item has changed in the Ofsted feed') do
  mock_ofsted_response JSON.load File.open "features/support/data/ofsted_response_changed_name.json"
end

And('a feed item has been added to the Ofsted feed') do
  mock_ofsted_response JSON.load File.open "features/support/data/ofsted_response_added_item.json"
end

And('the feed item has been removed from the Ofsted feed') do
  mock_ofsted_response JSON.load File.open "features/support/data/ofsted_response_deleted_item.json"
end

When('outpost is synchronised with the Ofsted feed') do
  rake.tasks.each {|t| t.reenable }
  rake.invoke_task('ofsted:update_items')
end

Then('the Ofsted item should be flagged for review') do
  @ofsted_item = OfstedItem.where(reference_number: 123456).first
  expect(@ofsted_item.provider_name).to eq 'Changed name'
  expect(@ofsted_item.status).to eq 'changed'
end

Then('an Ofsted item should be added') do
  expect(OfstedItem.count).to eq(2)
  new_ofsted_item = OfstedItem.where(reference_number: 234567).first
  expect(new_ofsted_item.provider_name).to eq 'New Provider'
  expect(new_ofsted_item.status).to eq 'new'
end

Then('the Ofsted item should be removed') do
  @ofsted_item = OfstedItem.where(reference_number: 123456).first
  expect(@ofsted_item.status).to eq 'deleted'
  expect(@ofsted_item.discarded_at).not_to be nil?
end

def mock_ofsted_response(hash)
  WebMock.stub_request(:get, /#{ENV['OFSTED_FEED_API_ENDPOINT']}\/.*/)
      .to_return(body: hash.to_json, headers: { 'Content-Type': 'application/json' })
end