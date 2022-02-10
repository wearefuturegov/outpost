desc 'Process permanents deletions'
task :process_permanent_deletions => :environment  do
  destroyed_services_count = 0
  destroyed_users_count = 0

  Service.discarded.each do |s|
    service_id = s.id
    next unless s.marked_for_deletion
    next unless s.marked_for_deletion <= DateTime.now.beginning_of_day - 30.days
    s.destroy_associated_data
    s.destroy
    puts "Destroyed service #{service_id} and dependents"
    destroyed_services_count += 1
  end

  User.discarded.each do |u|
    user_id = u.id
    next unless u.marked_for_deletion
    next unless u.marked_for_deletion <= DateTime.now.beginning_of_day - 30.days

    # Update the notes & versions
    u.notes.find_each do |note|
      note.update!(user_id: nil, deleted_user_name: u.display_name)
    end
    u.service_versions.find_each do |version|
      version.update(whodunnit: u.display_name)
    end

    u.destroy!
    puts "Destroyed user #{user_id}"
    destroyed_users_count += 1
  end

  puts "Destroyed #{destroyed_services_count} services and #{destroyed_users_count} users"
end
