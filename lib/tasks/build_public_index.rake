desc 'Build public index in the Mongo API'
task :build_public_index => :environment  do
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

    # 1. wipe the collection
    collection.delete_many({})

    # 2. insert new approved services (simple)
    approved_results = Service.where(approved: true, discarded_at: nil, visible: true).each do |result|
        collection.insert_one(IndexedServicesSerializer.new(result).as_json)
        puts "✅ #{result.name} indexed"
    end

    # 3. insert latest approved snapshots of unapproved services (complicated)
    unapproved_count = 0
    Service.where(approved: [false, nil]).each do |result|
        approved_alternative = result.last_approved_snapshot
        unless approved_alternative
            puts "🚨 No alternative approved snapshot of #{result.name} exists. Skipping."
            next
        end

        unless approved_alternative.object['visible'] == true && approved_alternative.object['discarded_at'].blank?
            puts "🚨 Approved snapshot of #{result.name} is not publicly visible. Skipping."
            next
        end

        collection.insert_one(IndexedServicesSerializer.new(Service.from_hash(approved_alternative.object)).as_json)
        puts "🤔 Alternative approved snapshot of #{result.name} indexed"
        unapproved_count = unapproved_count + 1
    end 

    client.close

    puts "\n\n 🏁🏁 SUMMARY 🏁🏁"
    puts "👉 #{approved_results.length} approved services added to index."
    puts "👉 #{unapproved_count} alternative snapshots of unapproved services added to index."
end
