require 'csv'

start_time = Time.now

# These two would be run when Ofsted Feed is switched
Rake::Task['ofsted:create_initial_items'].invoke
Rake::Task['users:create_users_from_file'].invoke

Rake::Task['organisations:create_from_csv'].invoke

Rake::Task['custom_fields:build_initial'].invoke

Rake::Task['taxonomy:create_categories_from_old_db'].invoke

Rake::Task['ofsted:set_open_objects_external_ids'].invoke

Rake::Task['services:create_from_csv'].invoke

end_time = Time.now

Rake::Task['taxonomy:map_to_new_taxonomy'].invoke
Rake::Task['taxonomy:delete_old_taxonomies'].invoke
Rake::Task['taxonomy:populate_parents'].invoke

all_needs_met_taxonomy = Taxonomy.where(name: "All needs met").first
all_needs_met_taxonomy.destroy! if all_needs_met_taxonomy.present?

puts "Took #{(end_time - start_time)/60} minutes"

# lock top-level taxa
Taxonomy.roots.each do |t|
  t.locked = true
  t.skip_mongo_callbacks = true
  unless t.save
    puts "Taxonomy #{t} failed to save: #{t.errors.messages}"
  end
end