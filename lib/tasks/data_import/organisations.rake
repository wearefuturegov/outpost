require 'csv'

namespace :import do
  namespace :organisations do

    desc 'Create organisations from CSV'
    task :create_from_csv => [ :environment ] do

      csv_file = File.open('lib/seeds/organisations.csv', "r:utf-8")
      data = CSV.parse(csv_file, headers: true)

      data.each do |row| # CREATE ORGS BASED ON TYPE
        if row['service_type'] == 'Organisation'
          organisation = Organisation.new
          organisation.name = row['title']
          organisation.description = ActionView::Base.full_sanitizer.sanitize(row['description'])
          organisation.email = row['contact_email']
          organisation.url = row['website']
          organisation.old_external_id = row['externalid']
          organisation.skip_mongo_callbacks = true
          unless organisation.save
            puts "Organisation #{organisation.name} failed to save: #{organisation.errors.messages}"
          end
        end
      end
    end

    task :separate_services_for_organisation, [:id] => :environment do |t, args|

      organisation = Organisation.find(args[:id])
      services = organisation.services

      services.each do |service|
        new_organisation = Organisation.new()
        new_organisation.skip_mongo_callbacks = true
        new_organisation.save!
        service.organisation_id = new_organisation.id
        puts "Setting #{service.name} org id to be #{new_organisation.id}"
        service.skip_mongo_callbacks = true
        service.save!
      end

      organisation.skip_mongo_callbacks = true
      organisation.destroy!

    end
  end
end
