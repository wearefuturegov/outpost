require 'rails_helper'
require 'rake'
rake = Rake::Application.new
Rake.application = rake
Rake::Task.define_task(:environment)

describe 'Ofsted feed synchronisation' do
  let (:run_rake_task) do
    Rake.application.invoke_task "ofsted:update_items"
  end

  before do
    ofsted_response = instance_double(HTTParty::Response, body: JSON.load(File.open("spec/fixtures/ofsted_response_start.json")).to_json)
    allow(HTTParty).to receive(:get).and_return(ofsted_response)
    Rake.application.invoke_task "ofsted:create_initial_items"
  end

  after(:each) do
    Rake::Task["ofsted:create_initial_items"].reenable
    Rake::Task["ofsted:update_items"].reenable
  end

  context 'with a new Ofsted feed item' do
    before do
      ofsted_response = instance_double(HTTParty::Response, body: JSON.load(File.open("spec/fixtures/ofsted_response_added_item.json")).to_json)
      allow(HTTParty).to receive(:get).and_return(ofsted_response)
    end

    it 'the item has been added' do
      run_rake_task

      expect(OfstedItem.count).to eq(2)
      new_ofsted_item = OfstedItem.where(reference_number: 234567).first
      expect(new_ofsted_item.provider_name).to eq 'New Provider'
      expect(new_ofsted_item.status).to eq 'new'
    end
  end

  context 'with an Ofsted feed item that has changed' do
    before do
      ofsted_response = instance_double(HTTParty::Response, body: JSON.load(File.open("spec/fixtures/ofsted_response_changed_name.json")).to_json)
      allow(HTTParty).to receive(:get).and_return(ofsted_response)
    end

    it 'the item is flagged for review' do
      run_rake_task

      ofsted_item = OfstedItem.where(reference_number: 123456).first
      expect(ofsted_item.provider_name).to eq 'Changed name'
      expect(ofsted_item.status).to eq 'changed'
    end
  end

  context 'with an Ofsted feed item that has been removed' do
    before do
      ofsted_response = instance_double(HTTParty::Response, body: JSON.load(File.open("spec/fixtures/ofsted_response_deleted_item.json")).to_json)
      allow(HTTParty).to receive(:get).and_return(ofsted_response)
    end

    it 'the item has been removed' do
      run_rake_task

      ofsted_item = OfstedItem.where(reference_number: 123456).first
      expect(ofsted_item.status).to eq 'deleted'
      expect(ofsted_item.discarded_at).not_to be nil?
    end
  end

end
