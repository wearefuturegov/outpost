require "rails_helper"
require 'fileutils'

Rails.application.load_tasks

describe 'Services import' do
  after(:each) do
    Rake::Task["import:services"].reenable
  end

  context 'with a valid CSV' do
    let(:valid_file_path) { Rails.root.join('spec', 'fixtures', 'data_import', 'services_valid.csv') }

    it 'works' do
      expect(Service.all.count).to eq 0
      expect(Link.all.reload.count).to eq 0
      Rake::Task["import:services"].invoke(valid_file_path)
      expect(Service.all.count).to eq 2
      expect(Link.all.count).to eq 2
    end

    context 'with the services imported already' do
      before do
        Rake::Task["import:services"].invoke(valid_file_path)
        Rake::Task["import:services"].reenable
      end

      it 'does not duplicate any services or other data' do
        expect(Service.all.count).to eq 2
        expect(Link.all.count).to eq 2
        expect(Suitability.all.count).to eq 10

        Rake::Task["import:services"].invoke(valid_file_path)

        expect(Service.all.count).to eq 2
        expect(Link.all.count).to eq 2
        expect(Suitability.all.count).to eq 10
      end
    end
  end

end
