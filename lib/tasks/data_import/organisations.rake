namespace :organisations do
    desc 'import tvp services from csv file to database'
    task :import, [:csv_parser] => [:environment] do |task, args|
       
        csv_parser = args[:csv_parser]        
        name_array = csv_parser['name']

        #remove nil from array
        compact_name_array = name_array.compact

        #find duplicated value in column Name
        duplicated_array = name_array.compact.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)

        if (duplicated_array.length > 0)
            raise "There is duplicate names in csv file: #{duplicated_array}"
        end

        #If any kind of unhandled error happens inside the block, the transaction will be aborted, and no changes will be made to the DB. - not need it from rollback
        ActiveRecord::Base.transaction do 
            csv_parser.each.with_index do |row, index|
                Organisation(row)
            end
        end

        puts 'End of importimporting data'
    end

    def Organisation(row)
        organisation = Organisation.new
        if row['organisation'].nil?
            organisation.name = 'Unnamed organisation'
        else
            organisation.name = row['organisation']
        end
        organisation.description = row['description']
        organisation.email = row['contact_email']
        organisation.url = row['url']
        organisation.save!
    end
end