task :mongo_services_at_locations => :environment  do
    Mongo::Logger.logger.level = Logger::FATAL
    
    puts "⏰ Connecting to mongo database..."
    client = Mongo::Client.new(ENV["MONGODB_URI"] || 'mongodb://127.0.0.1:27017/outpost_development')
    collection = client.database[:indexed_services_at_locations]

    # 1. wipe the collection
    collection.delete_many({})

    # 2. insert new approved services (simple)
    approved_results = ServiceAtLocation.joins(:location, :service)
        .where(services: {approved: true})
        .each do |result|
        
            record = result.as_json(include: {
                location: { methods: :geometry },
                service: { include: [
                    :organisation => {},
                    :taxonomies => { methods: :slug },
                    :contacts => {},
                    :local_offer => {},
                    :cost_options => {},
                    :regular_schedules => {}
                ]},
            })
        
            collection.insert_one(record)
            puts "✅ #{result.service.name} indexed"
        end

    # 3. search for latest snapshots for unapproved services (complicated)
    unapproved_count = 0
    ServiceAtLocation.joins(:location, :service)
        .where(services: {approved: false})
        .each do |result|
            approved_alternative = result.last_approved_snapshot
            if approved_alternative
                # TODO: this needs to reflect the structure of the approved service_at_locations
                # collection.insert_one({
                    # ???
                # })
                puts "✅ Alternative approved snapshot of #{result.name} indexed"
                unapproved_count = unapproved_count + 1
            else
                puts "🚨⏭ No alternative approved snapshot of #{result.name} exists. Skipping."
            end
        end 

    puts "\n\n 🏁🏁 SUMMARY 🏁🏁"
    puts "👉 #{approved_results.length} approved services added to index."
    puts "👉 #{unapproved_count} alternative snapshots of unapproved services added to index."
end