require 'csv'
namespace :forest_admin do

  task :import => :environment do
    start_time = Time.now
    
    Rake::Task['bod:users:create_users_from_file'].invoke
    Rake::Task['bod:custom_fields:build_initial'].invoke
    Rake::Task['bod:organisations:trim'].invoke
    Rake::Task['bod:services:import'].invoke
    Rake::Task['bod:taxonomy:import'].invoke
    Rake::Task['bod:services:import_opening_hours'].invoke
    Rake::Task['bod:users:set_ofsted_admins'].invoke
    Rake::Task['bod:services:mark_duplicates_as_bod'].invoke

    end_time = Time.now
    puts "Took #{(end_time - start_time)/60} minutes"
  end
end