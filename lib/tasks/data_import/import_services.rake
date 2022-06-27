require 'csv'
namespace :import_services do
    task :initial => :environment do
        start_time = Time.now

        file_path = Rails.root.join('lib', 'seeds', 'data-for-import.csv')
        file = File.open(file_path, "r:ISO-8859-1")
        csv_parser = CSV.parse(file, headers: true)

        Check_for_missing_data(csv_parser, 'import_id')

        #Check_for_missing_keys(csv_parser, ['import_id'])
        
        Check_for_non_numeric(csv_parser, 'import_id')

        Check_for_duplications(csv_parser, 'import_id')

        Check_for_missing_data(csv_parser, 'name', 'import_id_reference')

        Check_for_duplications(csv_parser, 'name')

        Check_for_duplications(csv_parser, 'organisation')

        csv_parser.each.with_index do |row, index|
            begin
                ActiveRecord::Base.transaction do
                    Service(csv_parser, row)
                    # Suitability(row)
                    # ReportPostcode(row)
                    # Accessibilities(row)
                end
            end
        end

        end_time = Time.now
        puts "Import completed, time for execution #{(end_time - start_time)/60} minutes"

        rescue StandardError => e 
            puts "Import aborted => : #{e.message}" 
    end

    def Check_for_missing_data(csv_parser, *args)
        puts "Checkig for missing #{args[0]} %s" %("and #{args[1]}" if args.length > 1)  

        column_data_array = csv_parser
        
        if (column_data_array.any?{ |item| (args.length > 1) ? item[args[0]].nil? && item[args[1]].nil? : item[args[0]].nil?})
                raise "There is missing #{args[0]} %s" %("and #{args[1]}" if args.length > 1) 
        end
    end

    # def Check_for_missing_keys(csv_parser, column_name)
    #     puts "Checkig for missing #{column_name[0]}"

    #     column_data_array = csv_parser[column_name[0]]

    #     if (column_data_array.any?{ |item| item.nil?})
    #         raise "There is missing #{column_name[0]} in csv file"
    #     end
    # end 

    def Check_for_duplications(csv_parser, column_name)
        puts "Checkig for duplicate #{column_name}"

        column_data_array = csv_parser[column_name]

        duplicated_column_data_array = column_data_array.compact.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)
        
        if (duplicated_column_data_array.length > 0)
            raise "There is duplicate #{column_name} in csv file: #{duplicated_column_data_array}"
        end
    end

    def Check_for_non_numeric(csv_parser, column_name)
        puts "Checkig #{column_name} for numeric"

        column_data_array = csv_parser[column_name]

        if column_data_array.any?{ |item| !CSV::Converters[:integer].call(item).is_a?(Numeric)}
            raise "CSV file contains non numeric #{column_name} keys"
        end
    end

    def Service(csv_parser, row)
        service = Service.new
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
        service.old_open_objects_external_id = row['import_id']
        service.organisation = Organisation(row)

        unless row['contact_name'].blank? && row['contact_email'].blank? && row['contact_phone'].blank?
            if row['import_id_reference'].blank?
                service.contacts << Service_Contact(row)
            else
                begin

                    parent_row = csv_parser.find {|item| item['import_id'] == row['import_id_reference']}
                    imported_service = Service.find_by(name: parent_row['name'])
                    imported_service.contacts << Service_Contact(row)
                    imported_service.save!

                rescue StandardError => e 
                    raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{imported_service.errors.messages}"
                end
            end
            
        end
        
        unless row['cost_amount'].blank?

            if row['import_id_reference'].blank?
                service.cost_options << Service_Cost(row)
            else
                begin

                    parent_row = csv_parser.find {|item| item['import_id'] == row['import_id_reference']}
                    imported_service = Service.find_by(name: parent_row['name'])
                    imported_service.cost_options << Service_Cost(row)
                    imported_service.save!

                rescue StandardError => e 
                    raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{imported_service.errors.messages}"
                end
            end

        end

        if !row['service_taxonomies'].nil?
            service_taxonomies_array = row['service_taxonomies'].split(';')
            service_taxonomies_array.each { |taxonomy_name|
                service.taxonomies << Taxonomy(taxonomy_name)
            }
        end

        unless row['schedules_opens_at'].blank? && row['schedules_closes_at'].blank? && row['scheduled_weekday'].blank?
            
            if row['import_id_reference'].blank?
                service.regular_schedules << RegularSchedule(row)
            else
                begin

                    parent_row = csv_parser.find {|item| item['import_id'] == row['import_id_reference']}
                    imported_service = Service.find_by(name: parent_row['name'])
                    imported_service.regular_schedules << RegularSchedule(row)
                    imported_service.save!

                rescue StandardError => e 
                    raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{imported_service.errors.messages}"
                end
            end
        end

        unless row['location_postcode'].blank?
            if row['import_id_reference'].blank?
                service.locations << Location(row)
            else
                begin

                    parent_row = csv_parser.find {|item| item['import_id'] == row['import_id_reference']}
                    imported_service = Service.find_by(name: parent_row['name'])
                    imported_service.locations << Location(row)
                    imported_service.save!

                rescue StandardError => e 
                    raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{imported_service.errors.messages}"
                end
            end
        end

        unless row['links_label'].blank? && row['links_url'].blank?
            if row['import_id_reference'].blank?
                service.links << Link(row)
            else
                begin

                    parent_row = csv_parser.find {|item| item['import_id'] == row['import_id_reference']}
                    imported_service = Service.find_by(name: parent_row['name'])
                    imported_service.links << Link(row)
                    imported_service.save!

                rescue StandardError => e 
                    raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{imported_service.errors.messages}"
                end
            end
        end

        service.save!

        rescue StandardError => e 
            raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{service.errors.messages}"
    end

    def Organisation(row)
        if row['import_id_reference'].blank?

            organisation = Organisation.new
            if row['organisation'].nil?
                organisation.name = 'Unnamed organisation'
            else
                organisation.name = row['organisation']
            end
            organisation.description = row['description']
            organisation.email = row['contact_email']
            organisation.url = row['url']
            organisation.old_external_id = row['import_id']
    
            organisation
        else
            organisation = Organisation.find_by(old_external_id: row['import_id_reference'])

            organisation
        end
        
    end

    def RegularSchedule(row)

        days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']

        scheduled = RegularSchedule.new
        scheduled.opens_at = row['schedules_opens_at']
        scheduled.closes_at = row['schedules_closes_at']
        scheduled.weekday = days.find_index(row['scheduled_weekday'].downcase)

        scheduled
    end

    def Service_Contact(row)
        contact = Contact.new
        contact.name = row['contact_name']
        contact.title = row['contact_title']
        contact.visible = row['contact_visible']
        contact.email = row['contact_email']
        contact.phone = row['contact_phone']
        
        contact
    end

    def Service_Cost(row)
        costoption = CostOption.new
        costoption.option = row['cost_option']
        costoption.amount = row['cost_amount']
        costoption.cost_type = row['cost_type']
        
        costoption
    end

    def Taxonomy(taxonomy_name)
        taxonomy = Taxonomy.new
        taxonomy.name = taxonomy_name
        
        taxonomy
    end

    def Suitability(row)
        if !row['suitabilities'].nil?
            suitabilities_array = row['suitabilities'].split(';')
            suitabilities_array.each { |suitability_name|
                begin
                    suitability = Suitability.new
                    suitability.name = suitability_name
                    suitability.save! 
                rescue StandardError => e 
                    raise "An error occurred while importing Suitability in row #{row['import_id']} failed to save: #{suitability.errors.messages}"
                end
            }
        end
    end

    def ReportPostcode(row)
        reportPostCode = ReportPostcode.new
        reportPostCode.postcode = row['location_postcode']
        reportPostCode.save!

        rescue StandardError => e 
            raise "An error occurred while importing ReportPostcode in row #{row['import_id']} failed to save: #{reportPostCode.errors.messages}"
    end

    def Accessibilities(row)
        if !row['location_accessibilities'].nil?
            accessibilities_array = row['location_accessibilities'].split(';')
            accessibilities_array.each { |accessibilities_name|
                begin
                    accessibility = Accessibility.new
                    accessibility.name = accessibilities_name
    
                    accessibility.locations << Location(row)
                   
                    accessibility.save!
                rescue StandardError => e 
                    raise "An error occurred while importing Accessibility in row #{row['import_id']} failed to save: #{accessibility.errors.messages}"
                end
            }
        end
    end

    def Location(row)
        location = Location.new
        location.name = row['location_name']
        location.latitude = row['location_latitude']
        location.longitude = row['location_longitude']
        location.address_1 = row['location_address_1']
        location.city = row['location_city']
        location.postal_code = row['location_postcode']
        location.visible = row['location_visible']
        location.mask_exact_address = row['mask_exact_address']
        location.preferred_for_post = row['preferred_for_post']

        location
    end

    def Link(row)
        link = Link.new
        link.label = row['links_label']
        link.url = row['links_url']

        link
    end
end