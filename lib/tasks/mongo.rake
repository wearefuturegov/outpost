task :mongo => :environment  do

    puts "⏰ Connecting to mongo database..."
    client = Mongo::Client.new(ENV["MONGODB_URI"] || 'mongodb://127.0.0.1:27017/outpost_development')
    collection = client.database[:indexed_services]

    # 1. wipe the collection
    collection.drop

    # 2. insert new approved services (simple)
    approved_results = Service.where(approved: true).each do |result|
        collection.insert_one(result.as_json)
        puts "✅ #{result.name} indexed"
    end

    # 3. search for latest snapshots for unapproved services (complicated)
    unapproved_count = 0
    Service.where(approved: false).each do |result|
        approved_alternative = result.last_approved_snapshot
        if approved_alternative
            collection.insert_one(approved_alternative.object)
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