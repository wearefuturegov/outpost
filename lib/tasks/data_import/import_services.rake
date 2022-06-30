require 'csv'
namespace :import_services do
    task :initial => :environment do
        start_time = Time.now

        file_path = Rails.root.join('lib', 'seeds', 'TVP services for import - Service Data.csv')
        file = File.open(file_path, "r:ISO-8859-1")
        csv_parser = CSV.parse(file, headers: true)

        Check_for_missing_data(csv_parser, 'import_id')

        Check_for_non_numeric(csv_parser, 'import_id')

        Check_for_duplications(csv_parser, 'import_id')

        Check_for_missing_data(csv_parser, 'name', 'import_id_reference')

        Check_for_duplications(csv_parser, 'name')

        csv_parser.each.with_index do |row, index|
            begin
                ActiveRecord::Base.transaction do
                    create_service(csv_parser, row)
                    create_report_postcode(row)
                    create_accessibilities(row)
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

    def create_service(csv_parser, row)

        isNewService = true
        if row['name'].blank?
            if !row['import_id_reference'].blank?
                isNewService = false
            end
        end
        service = nil if false
        
        if !isNewService
            begin
                parent_row = csv_parser.find {|item| item['import_id'] == row['import_id_reference']}
                service = Service.find_by(name: parent_row['name'].strip)
                service.organisation = Organisation.find_by(name: parent_row['organisation'].strip)
            end
        else
            begin
                service = Service.create
                service.name = row['name'].strip
                service.description = row['description']
                service.url = row['url']
                service.approved = row['approved']
                service.visible_from = row['visible_from']
                service.visible_to = row['visible_to']

                if !row['visible_from'].nil? && !row['visible_to'].nil?
                    service.visible = true
                else 
                    service.visible = row['visible']
                end

                service.min_age = row['min_age']
                service.max_age = row['max_age']
                service.free = row['free']
                service.old_open_objects_external_id = row['import_id']
                service.organisation = create_organisation(row)
            end
        end

        unless row['contact_name'].blank? && row['contact_email'].blank? && row['contact_phone'].blank?
            service.contacts << create_service_contact(row)
        end
        
        unless row['cost_amount'].blank?
            service.cost_options << create_service_cost(row)
        end

        unless row['schedules_opens_at'].blank? && row['schedules_closes_at'].blank? && row['scheduled_weekday'].blank?
            service.regular_schedules << create_regular_schedule(row)
        end

        unless row['location_postcode'].blank?
            service.locations << create_location(row)
        end

        if !row['links_label'].blank? && !row['links_url'].blank?
            service.links << create_link(row)
        end

        if !row['service_taxonomies'].nil?
            service_taxonomies_array = row['service_taxonomies'].split(';')
            service_taxonomies_array.each { |taxonomy_name|
                
                if !taxonomy_name.blank?
                    existing_taxonomy = Taxonomy.find_by(name: taxonomy_name.strip)
                    if existing_taxonomy.nil?
                        service.taxonomies << create_taxonomy(taxonomy_name.strip)
                    else
                        service.taxonomies << existing_taxonomy
                    end
                end
            }
        end

        if !row['suitabilities'].nil?
            service_suitabilities_array = row['suitabilities'].split(';')
            service_suitabilities_array.each { |suitability_name|
            
                if !suitability_name.blank?
                    existing_suitability = Suitability.find_by(name: suitability_name.strip)
                    if existing_suitability.nil?
                        service.suitabilities << create_suitability(suitability_name.strip)
                    else
                        service.suitabilities << existing_suitability
                    end
                end
            }
        end

        if !row['send_needs_support'].nil?
            service_needs_support_array = row['send_needs_support'].split(';')
            service_needs_support_array.each { |support_name|
            
                if !support_name.blank?
                    existing_support = SendNeed.find_by(name: support_name.strip)
                    if existing_support.nil?
                        service.send_needs << create_send_need(support_name.strip)
                    else
                        service.send_needs << existing_support
                    end
                end
            }
        end

        service.save

        rescue StandardError => e
            raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{service.errors.messages}"
    end

    def create_organisation(row)
        organisation = Organisation.new
        if row['organisation'].nil?
            organisation.name = "Unnamed organisation"
        else
            organisation.name = row['organisation'].strip
        end
        organisation.description = row['description']
        organisation.email = row['contact_email']
        organisation.url = row['url']
        organisation.old_external_id = row['import_id']

        organisation
    end

    def create_regular_schedule(row)

        days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']

        scheduled = RegularSchedule.new
        scheduled.opens_at = row['schedules_opens_at']
        scheduled.closes_at = row['schedules_closes_at']
        scheduled.weekday = days.find_index(row['scheduled_weekday'].downcase)
        scheduled
    end

    def create_service_contact(row)
        contact = Contact.new
        contact.name = row['contact_name']
        contact.title = row['contact_title']
        contact.visible = row['contact_visible']
        contact.email = row['contact_email']
        contact.phone = row['contact_phone']
        
        contact
    end

    def create_service_cost(row)
        costoption = CostOption.new
        costoption.option = row['cost_option']
        costoption.amount = row['cost_amount']
        costoption.cost_type = row['cost_type']
        
        costoption
    end

    def create_taxonomy(taxonomy_name)
        taxonomy = Taxonomy.new
        taxonomy.name = taxonomy_name
        
        taxonomy
    end

    def create_suitability(suitability_name)
        suitability = Suitability.new
        suitability.name = suitability_name
        
        suitability
    end

    def create_send_need(support_name)
        sendNeed = SendNeed.new
        sendNeed.name = support_name
        
        sendNeed
    end

    def create_report_postcode(row)
       if row['import_id_reference'].blank?
        begin
            reportPostCode = ReportPostcode.new
            reportPostCode.postcode = row['location_postcode']
            reportPostCode.save!
    
            rescue StandardError => e 
                raise "An error occurred while importing ReportPostcode in row #{row['import_id']} failed to save: #{reportPostCode.errors.messages}"
        end
       end
    end

    def create_accessibilities(row)
        if !row['location_accessibilities'].nil?
            accessibilities_array = row['location_accessibilities'].split(';')
            accessibilities_array.each { |accessibilities_name|
                begin
                    existing_accessibility = Accessibility.find_by(name: accessibilities_name.strip)

                    if existing_accessibility.nil?
                        accessibility = Accessibility.new
                        accessibility.name = accessibilities_name.strip
        
                        accessibility.locations << create_location(row)
                    
                        accessibility.save!
                    end
                    
                rescue StandardError => e 
                    raise "An error occurred while importing Accessibility in row #{row['import_id']} failed to save: #{accessibility.errors.messages}"
                end
            }
        end
    end

    def create_location(row)
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

    def create_link(row)
        link = Link.new
        link.label = row['links_label']
        link.url = row['links_url']

        link
    end
end