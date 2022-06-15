namespace :services do
    desc 'import tvp services from csv file to database'
    task :import, [:csv_parser] => [:environment] do |task, args|
       
        csv_parser = args[:csv_parser]        

        #If any kind of unhandled error happens inside the block, the transaction will be aborted, and no changes will be made to the DB. - not need it from rollback
        ActiveRecord::Base.transaction do 
            csv_parser.each.with_index do |row, index|
                Services(row)
            end
        end

        puts 'End of importimporting data'
    end

    def Services(row)
        
        if row['service_type'] == 'Service'
            organisation = Organisation.find_by(old_external_id: row['import_id_reference'])
            if organisation != nil
                service = Service.new
                service.organisation_id = organisation.id
                service.name = row['name']
                service.description = row['description']
                service.url = row['url']
                service.approved = row['approved']
                service.visible_from = row['visible_from']
                service.visible_to = row['visible_to']
    
                if !row['visible_from'].nil? && !row['visible_to'].nil?
                    service.visible = false
                else 
                    service.visible = row['visible']
                end
    
                service.min_age = row['min_age']
                service.max_age = row['max_age']
                service.free = row['free']
                service.save!
            end
        end

    end
end