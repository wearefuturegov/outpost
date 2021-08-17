require 'csv'
namespace :open_objects do
  task :import => :environment do

    start_time = Time.now

    # These two would be run when Ofsted Feed is switched
    Rake::Task['ofsted:create_initial_items'].invoke
    Rake::Task['users:create_users_from_file'].invoke

    Rake::Task['organisations:create_from_csv'].invoke

    Rake::Task['custom_fields:build_initial'].invoke

    Rake::Task['taxonomy:create_categories_from_old_db'].invoke

    Rake::Task['ofsted:set_open_objects_external_ids'].invoke

    Rake::Task['services:create_from_csv'].invoke
    Rake::Task['services:set_send_report_links'].invoke
    Rake::Task['services:import_opening_hours'].invoke
    Rake::Task['services:import_costs'].invoke
    
    Rake::Task['report_postcodes:import'].invoke

    Rake::Task['taxonomy:map_to_new_taxonomy'].invoke
    Rake::Task['taxonomy:delete_old_taxonomies'].invoke
    Rake::Task['taxonomy:populate_parents'].invoke
    Rake::Task['taxonomy:remove_all_needs_met'].invoke
    Rake::Task['taxonomy:reset_counters'].invoke
    Rake::Task['taxonomy:lock_top_level'].invoke

    end_time = Time.now

    puts "Took #{(end_time - start_time)/60} minutes"
  end
end