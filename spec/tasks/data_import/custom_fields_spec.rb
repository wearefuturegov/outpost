require "rails_helper"
require 'fileutils'

Rails.application.load_tasks

describe 'Custom fields import' do
  let(:seed_file_destination) { Rails.root.join('lib', 'seeds', 'custom-fields.csv') }

  after(:each) do
    Rake::Task["process_permanent_deletions"].reenable
  end

  context 'with a valid CSV' do
    before do
      valid_file = Rails.root.join('spec', 'fixtures', 'data_import', 'custom_fields_valid.csv')
      FileUtils.cp(valid_file, seed_file_destination)
    end

    it 'works' do
      expect(CustomFieldSection.all.count).to eq 0
      expect(CustomField.all.count).to eq 0
      Rake::Task['import:custom_fields'].invoke
      expect(CustomFieldSection.all.count).to eq 1
      expect(CustomField.all.count).to eq 5
    end
  end

end
