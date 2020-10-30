require 'csv'

namespace :organisations do

  task :create_from_csv => [ :environment ] do

    csv_file = File.open('lib/seeds/bucksfis geo.csv', "r:utf-8")
    bucks_csv = CSV.parse(csv_file, headers: true)

    bucks_csv.each do |row| # CREATE ORGS BASED ON TYPE
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
end