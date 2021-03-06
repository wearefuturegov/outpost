task :process_permanent_deletions => :environment  do
    destroyed_services_count = 0
    destroyed_users_count = 0

    Service.discarded.each do |s|
      service_id = s.id
      next unless s.marked_for_deletion
      next unless s.marked_for_deletion <= DateTime.now.beginning_of_day - 30.days
      s.snapshots.destroy_all
      s.service_at_locations.destroy_all
      s.service_taxonomies.destroy_all
      s.contacts.destroy_all
      s.local_offer&.destroy
      s.regular_schedules.destroy_all
      s.cost_options.destroy_all
      s.feedbacks.destroy_all
      s.notes.destroy_all
      s.watches.destroy_all
      s.destroy
      puts "Destroyed service #{service_id} and dependents"
      destroyed_count += 1
    end

    User.discarded.each do |u|
      user_id = u.id
      next unless u.marked_for_deletion
      next unless u.marked_for_deletion <= DateTime.now.beginning_of_day - 30.days
      u.destroy
      puts "Destroyed user #{user_id}"
      destroyed_count += 1
    end

    puts "Destroyed #{destroyed_services_count} services and #{destroyed_users_count} users"
end