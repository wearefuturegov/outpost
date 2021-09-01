require 'csv'
namespace :forest_admin do

  task :import => :environment do
    start_time = Time.now
    
    Rake::Task['bod:services:apply_bfis_directory_to_current'].invoke
    Rake::Task['bod:users:create_users_from_file'].invoke
    Rake::Task['bod:custom_fields:build_initial'].invoke
    Rake::Task['bod:services:import'].invoke
    Rake::Task['bod:taxonomies:import'].invoke
    Rake::Task['bod:services:import_opening_hours'].invoke

    end_time = Time.now
    puts "Took #{(end_time - start_time)/60} minutes"
  end
end