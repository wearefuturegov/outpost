require 'csv'
namespace :forest_admin do

  task :import => :environment do
    start_time = Time.now
    
    #Rake::Task['bod:services:apply_bfis_label_to_current'].invoke
    Rake::Task['bod:users:create_users_from_file'].invoke
    Rake::Task['bod:services:import'].invoke

    end_time = Time.now
    puts "Took #{(end_time - start_time)/60} minutes"
  end
end