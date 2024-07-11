desc 'Compare Outpost and public index in the Mongo API'
task :check_public_index => :environment  do
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


    active_services, temporarily_closed_services, scheduled_services, archived_services, expired_services, invisible_services, marked_for_deletion_services, pending_services = [], [], [], [], [], [], [], []


    mongo_ids = collection.find.map { |doc| doc[:id] }

    Service.find_each do |service|
        case service.status 
        when 'active'
            if !mongo_ids.include?(service.id)
                active_services << service
            end
        when 'temporarily closed'
            if !mongo_ids.include?(service.id)
                temporarily_closed_services << service
            end
        when 'scheduled'
            if !mongo_ids.include?(service.id)
                scheduled_services << service
            end
        when 'archived'
            if mongo_ids.include?(service.id)
                archived_services << service
            end
        when 'expired'
            if mongo_ids.include?(service.id)
                expired_services << service
            end
        when 'invisible'
            if mongo_ids.include?(service.id)
                invisible_services << service
            end
        when 'marked for deletion'
            if mongo_ids.include?(service.id)
                marked_for_deletion_services << service
            end
        when 'pending'
            approved_alternative = service.last_approved_snapshot
            if approved_alternative && approved_alternative.object['visible'] == true && approved_alternative.object['discarded_at'].blank?
                if !mongo_ids.include?(service.id)
                    pending_services << service
                end
            end
        end
    end

    


    puts "Active services not in index: #{active_services.count}"
    active_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end
    puts "Temporarily closed services not in index: #{temporarily_closed_services.count}"
    temporarily_closed_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end
    puts "Scheduled services not in index: #{scheduled_services.count}"
    scheduled_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end
    puts "Archived services in index: #{archived_services.count}"
    archived_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end
    puts "Expired services in index: #{expired_services.count}"
    expired_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end
    puts "Invisible services in index: #{invisible_services.count}"
    invisible_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end
    puts "Marked for deletion services in index: #{marked_for_deletion_services.count}"
    marked_for_deletion_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end
    puts "Pending services not in index: #{pending_services.count}"
    pending_services.each do |service|
        puts "#{service.id} - #{service.name} - #{service.status} - #{service.updated_at}"
    end

    
end


def create_update_service(service)
end