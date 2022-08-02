require "rails_helper"
require 'fileutils'

Rails.application.load_tasks

describe 'Services import' do
  let(:seed_file_destination) { Rails.root.join('lib', 'seeds', 'custom-fields.csv') }

  after(:each) do
    Rake::Task["import:services"].reenable
  end

  context 'with a valid CSV' do
    let(:valid_file_path) { Rails.root.join('spec', 'fixtures', 'data_import', 'services_valid.csv') }

    it 'works' do
      expect(Service.all.count).to eq 0
      Rake::Task["import:services"].invoke(valid_file_path)
      expect(Service.all.count).to eq 2
    end

    context 'with the services imported already' do
      before do
        Rake::Task["import:services"].invoke(valid_file_path)
        Rake::Task["import:services"].reenable
      end

      it 'does not duplicate any services' do
        expect(Service.all.count).to eq 2
        Rake::Task["import:services"].invoke(valid_file_path)
        expect(Service.all.count).to eq 2
      end
    end
  end

end
