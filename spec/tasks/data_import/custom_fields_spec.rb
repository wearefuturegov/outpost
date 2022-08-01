require "rails_helper"
require 'fileutils'

Rails.application.load_tasks

describe 'Custom fields import' do
  let(:seed_file_destination) { Rails.root.join('lib', 'seeds', 'custom-fields.csv') }

  after(:each) do
    Rake::Task["import:custom_fields"].reenable
  end

  context 'with a valid CSV' do
    let(:valid_file_path) { Rails.root.join('spec', 'fixtures', 'data_import', 'custom_fields_valid.csv') }

    it 'works' do
      expect(CustomFieldSection.all.count).to eq 0
      expect(CustomField.all.count).to eq 0
      Rake::Task["import:custom_fields"].invoke(valid_file_path)
      expect(CustomFieldSection.all.count).to eq 1
      expect(CustomField.all.count).to eq 5
    end
  end

end
