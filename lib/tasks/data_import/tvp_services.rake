require 'csv'
namespace :tvp_services do
    task :import => :environment do
        start_time = Time.now

        #file_path = Rails.root.join('lib', 'tasks', 'data_import', 'data-import--with-sample-data.csv')
        file_path = Rails.root.join('lib', 'seeds', 'TVP services for import - Service Data.csv')
        file = File.open(file_path, "r:ISO-8859-1")
        csv_parser = CSV.parse(file, headers: true)

        puts 'Organisations data importing'
        Rake::Task['organisations:import'].invoke(csv_parser)
        
    rescue StandardError => e 
        puts "Import aborted => : #{e.message}" 

        end_time = Time.now
        puts "Took #{(end_time - start_time)/60} minutes"
    end
end