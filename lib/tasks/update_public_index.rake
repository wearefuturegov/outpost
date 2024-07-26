# This can be quite difficult to debug so in the tests 
# there is a commented out test that will help you 
# generate all sorts of scenarios on top of the tests themselves

desc 'Update Outpost public index copies in the Mongo API'
task :update_public_index => :environment  do
    # Turn off logging for this rake task, otherwise it just fills up our logs
    dev_null = Logger.new('/dev/null')
    Rails.logger = dev_null
    ActiveRecord::Base.logger = dev_null

    Mongo::Logger.logger.level = Logger::FATAL

    puts "⏰ Connecting to mongo database...\n\n"
    client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://root:password@localhost:27017/outpost_development?authSource=admin', {
        retry_writes: false
    })
    collection = client.database[:indexed_services]
    approved_count, unapproved_count, deleted_count, deleted_skipped_count = 0, 0, 0, 0
    active_count, temporarily_closed_count, scheduled_count, archived_count, expired_count, invisible_count, marked_for_deletion_count, pending_count = 0, 0, 0, 0, 0, 0, 0, 0
    active_ids, temporarily_closed_ids, scheduled_ids, archived_ids, expired_ids, invisible_ids, marked_for_deletion_ids, pending_ids, archived_skipped_ids, expired_skipped_ids, invisible_skipped_ids, marked_for_deletion_skipped_ids, pending_skipped_ids = [], [], [], [], [], [], [], [], [], [], [], [], []

    Service.find_each do |service|
        case service.status 

        # active services are all indexed
        when 'active'
            collection.find_one_and_update({ id: service.id },
                                        IndexedServicesSerializer.new(service).as_json,
                                        { upsert: true })
            active_count += 1
            puts "🟢 ACTV: #{service.id} #{service.name} indexed"
            active_ids << service.id

        # temporarily closed services are all indexed
        when 'temporarily closed'
            collection.find_one_and_update({ id: service.id },
                                        IndexedServicesSerializer.new(service).as_json,
                                        { upsert: true })
            temporarily_closed_count += 1
            puts "🟢 TEMP: #{service.id} #{service.name} indexed"
            temporarily_closed_ids << service.id

        # scheduled services are all indexed - the API determines if they're returned or not
        when 'scheduled'
            collection.find_one_and_update({ id: service.id },
                                        IndexedServicesSerializer.new(service).as_json,
                                        { upsert: true })
            scheduled_count += 1
            puts "🟢 SCHD: #{service.id} #{service.name} indexed"
            scheduled_ids << service.id


        # archived services are removed from the index
        when 'archived'
            deleted_archived = collection.find_one_and_delete({ id: service.id })
            archived_count += 1
            if deleted_archived
                archived_ids << service.id
                puts "🔴 ARCH: #{service.id} #{service.name} DELETED"
            else 
                archived_skipped_ids << service.id
                puts "🟡 ARCH: #{service.id} #{service.name} not found in index, skipping"
            end

        # expired services are removed from the index
        when 'expired'
            deleted_expired = collection.find_one_and_delete({ id: service.id })
            expired_count += 1
            if deleted_expired
                expired_ids << service.id
                puts "🔴 EXPD: #{service.id} #{service.name} DELETED"
            else 
                expired_skipped_ids << service.id
                puts "🟡 EXPD: #{service.id} #{service.name} not found in index, skipping"
            end

        # invisible services are removed from the index
        when 'invisible'
            deleted_invisible = collection.find_one_and_delete({ id: service.id })
            invisible_count += 1
            if deleted_invisible
                invisible_ids << service.id
                puts "🔴 INVS: #{service.id} #{service.name} DELETED"
            else 
                invisible_skipped_ids << service.id
                puts "🟡 INVS: #{service.id} #{service.name} not found in index, skipping"
            end

        # marked for deletion definitely get removed from the index
        when 'marked for deletion'
            deleted_marked_for_deletion = collection.find_one_and_delete({ id: service.id })
            marked_for_deletion_count += 1
            if deleted_marked_for_deletion
                marked_for_deletion_ids << service.id
                puts "🔴 MKDL: #{service.id} #{service.name} DELETED"
            else 
                marked_for_deletion_skipped_ids << service.id
                puts "🟡 MKDL: #{service.id} #{service.name} not found in index, skipping"
            end

        # if status is pending we work off last version where approved === true, if it exists and is visible or we make a snapshot to make it visible
        when 'pending'
            pending_count += 1

            puts "⚪️ PEND: #{service.id} #{service.name}"
            puts "\s\s\s\s\s- Service has #{service.versions.count} versions"
            puts "\s\s\s\s\s- Service has #{service.last_approved_snapshot ? 'a' : 'no'} previously approved snapshot"
            if service.last_approved_snapshot
                puts "\s\s\s\s\s\s\s- approved snapshot is #{service.last_approved_snapshot.object['visible'] == true ? 'visible' : 'invisible'}"
                puts "\s\s\s\s\s\s\s- approved snapshot is #{service.last_approved_snapshot.object['discarded_at'].blank? ? 'not discarded' : 'discarded'}"
            end

              approved_alternative = service.last_approved_snapshot
              unless approved_alternative
                pending_skipped_ids << service.id
                puts "\s\s\s\s\s- 🟡 No approved version for #{service.id} #{service.name} exists. Skipping."
                next
              end
        
              unless approved_alternative.object['visible'] == true && approved_alternative.object['discarded_at'].blank?
                pending_skipped_ids << service.id
                puts "\s\s\s\s\s- 🟠 Approved version of #{service.id} #{service.name} exists but it is not publicly visible. Skipping."
                next
              end
        
              snapshot = Service.from_hash(approved_alternative.object)
              collection.find_one_and_update({ id: service.id },
                                             IndexedServicesSerializer.new(snapshot).as_json,
                                             { upsert: true })
              puts "\s\s\s\s\s- 🟢 Last approved version (id: #{approved_alternative.id}) of #{service.id} #{service.name} indexed"
              pending_ids << service.id
        end
    end


    # check if we missed any entries, best to be safe and remove them
    indexed_ids = active_ids + temporarily_closed_ids + scheduled_ids + pending_ids
    missed_services = collection.find({ id: { '$nin': indexed_ids.sort } })

    if missed_services and missed_services.count > 0
        puts "\n\n"
        puts "#{missed_services.count} services exist in mongo but not in outpost, deleting..."
        missed_service_ids = missed_services.map { |service| service['id'] }
        delete_missed_services = collection.delete_many({ id: { '$in': missed_service_ids } })
        puts "#{delete_missed_services.deleted_count} unaccounted for services deleted."
    else 
        puts "\n\n"
        puts "No unaccounted for services left in the index."
    end
      
    skipped_ids = archived_skipped_ids + expired_skipped_ids + invisible_skipped_ids + marked_for_deletion_skipped_ids + pending_skipped_ids
    deleted_ids = archived_ids + expired_ids + invisible_ids + marked_for_deletion_ids

    puts "\n\n"
    puts "🏁🏁 SUMMARY 🏁🏁"
    puts " 👉 #{indexed_ids.length} updated or created"
    puts " 👉 #{skipped_ids.length} skipped"
    puts " 👉 #{deleted_ids.length} deleted"
    
    puts "\n\n\n"
    puts "Updated or Created Services"
    puts " 👉 #{active_count} active services, #{active_ids.length} created or updated"
    puts " 👉 #{temporarily_closed_count} temporarily_closed services, #{temporarily_closed_ids.length} created or updated"
    puts " 👉 #{scheduled_count} scheduled services, #{scheduled_ids.length} created or updated"
    
    puts "\n\n\n"
    puts "Deleted Services"
    puts " 👉 #{archived_count} archived services, #{archived_ids.length} deleted"
    puts " 👉 #{expired_count} expired services, #{expired_ids.length} deleted"
    puts " 👉 #{invisible_count} invisible services, #{invisible_ids.length} deleted"
    puts " 👉 #{marked_for_deletion_count} marked_for_deletion services, #{marked_for_deletion_ids.length} deleted"

    puts "\n\n\n"
    puts "Pending Services"
    puts " 👉 #{pending_count} pending services, #{pending_ids.length} created or updated."
end
