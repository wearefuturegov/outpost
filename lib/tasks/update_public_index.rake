desc 'Update public index in the Mongo API'
task :update_public_index => :environment  do
  # Turn off logging for this rake task, otherwise it just fills up our logs
  dev_null = Logger.new('/dev/null')
  Rails.logger = dev_null
  ActiveRecord::Base.logger = dev_null

  Mongo::Logger.logger.level = Logger::FATAL

  puts "⏰ Connecting to mongo database..."
  client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://root:password@localhost:27017/outpost_development?authSource=admin', {
    retry_writes: false
  })
  collection = client.database[:indexed_services]

  approved_count, unapproved_count, deleted_count, deleted_skipped_count = 0, 0, 0, 0

  Service.find_each do |service|

    case service.status
    when 'active', 'temporarily closed'
      collection.find_one_and_update({ id: service.id },
                                     IndexedServicesSerializer.new(service).as_json,
                                     { upsert: true })
      puts "✅ #{service.name} indexed"
      approved_count += 1

    when 'archived', 'marked for deletion', 'invisible', 'scheduled', 'expired'

      deleted = collection.find_one_and_delete({ id: service.id })
      if deleted
        puts "✅ 🚮 #{service.name} deleted"
        deleted_count += 1
      else
        puts "✅ 🚮 #{service.name} not found in index, skipping"
        deleted_skipped_count += 1
      end

    when 'pending'
      approved_alternative = service.last_approved_snapshot
      unless approved_alternative
        puts "🚨 No alternative approved snapshot of #{service.name} exists. Skipping."
        next
      end

      unless approved_alternative.object['visible'] == true && approved_alternative.object['discarded_at'].blank?
        puts "🚨 Approved snapshot of #{service.name} is not publicly visible. Skipping."
        next
      end

      snapshot = Service.from_hash(approved_alternative.object)
      collection.find_one_and_update({ id: service.id },
                                     IndexedServicesSerializer.new(snapshot).as_json,
                                     { upsert: true })
      puts "🤔 Alternative approved snapshot of #{service.name} indexed"
      unapproved_count += 1
    end
  end

  puts "\n\n 🏁🏁 SUMMARY 🏁🏁"
  puts "👉 #{approved_count} approved services added to index."
  puts "👉 #{unapproved_count} alternative snapshots of unapproved services added to index."
  puts "👉 #{deleted_count} deleted or expired services removed from index."
  puts "👉 #{deleted_skipped_count} deleted or expired services not found in index."
end
