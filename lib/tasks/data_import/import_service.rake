require 'csv'
namespace :import_services do
    task :initial => :environment do
        start_time = Time.now
        
        system ("cls")

        file_path = Rails.root.join('lib', 'seeds', 'TVP services for import - Service Data.csv')
        file = File.open(file_path, "r:ISO-8859-1")
        csv_parser = CSV.parse(file, headers: true)

        Check_for_missing_data(csv_parser, 'import_id')

        Check_for_non_numeric(csv_parser, 'import_id')

        Check_for_duplications(csv_parser, 'import_id')

        Check_for_missing_data(csv_parser, 'name', 'import_id_reference')

        Check_for_duplications(csv_parser, 'name')

        puts "All checks has finished successfully"
        
        puts "Import starts"

        csv_parrent_service_array = csv_parser.filter() {|row| row['import_id_reference'].blank?}

        csv_parrent_service_array.each.with_index do |row, index|
            begin
                is_successful_imported = import_service(csv_parser, row)
                
                puts "Importing service #{row['name']} with id #{row['import_id']} - #{is_successful_imported ? 'done' : 'skipped'}"
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

    def import_service(csv_parser, parent_row)
        service = Service.find_by(name: parent_row['name'].strip)
        is_successful_imported = false
        ActiveRecord::Base.transaction do
            unless !service.nil?
                service = create_new_service(parent_row)
            
                service_array = csv_parser.filter() { |row| (row['import_id'] == parent_row['import_id'] || row['import_id_reference'] == parent_row['import_id'])}

                service_array.each.with_index do |row, index|
                    unless row['schedules_opens_at'].blank? && row['schedules_closes_at'].blank? && row['scheduled_weekday'].blank?
                        service.regular_schedules << create_regular_schedule(row)
                    end

                    unless row['contact_name'].blank? && row['contact_email'].blank? && row['contact_phone'].blank?
                        service.contacts << create_service_contact(row)
                    end

                    unless row['cost_amount'].blank?
                        service.cost_options << create_service_cost(row)
                    end

                    unless row['service_taxonomies'].nil?
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

                    unless row['suitabilities'].nil?
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

                    unless row['send_needs_support'].nil?
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

                    if !row['links_label'].blank? && !row['links_url'].blank?
                        service.links << create_link(row)
                    end
                    
                    unless !row['import_id_reference'].blank?
                        create_report_postcode(row)
                    end

                    unless row['location_accessibilities'].blank?
                        create_accessibilities(row)
                    end

                    unless row['notes'].blank?
                        service.notes << create_notes(row)
                    end

                    unless !row['import_id_reference'].blank?
                        custom_field = CustomField.all()
                        custom_field.each{ |item|
                            column_name = "custom_#{item.field_type.downcase}_#{item.key.downcase}"
                            unless row[column_name].blank?
                                service.meta << create_custom_field(item.key, row[column_name])
                            end
                        }
                    end
                end

                service.save
                is_successful_imported = true
            end
        rescue StandardError => e
            raise "An error occurred while importing Service in row #{row['import_id']} failed to save: #{service.errors.messages}"
        end
    end

    def create_new_service(row)
        service = Service.create
        service.name = row['name'].strip
        service.description = row['description']
        service.url = row['url']
        service.approved = row['approved']
        service.visible_from = row['visible_from']
        service.visible_to = row['visible_to']
        service.needs_referral = row["needs_referral"]
        service.temporarily_closed = row["temporarily_closed"]
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

        service
    end

    def create_organisation(row)

        organisation = nil if false

        organisation_name = row['organisation']

        if organisation_name.blank?
            organisation_name = "Unnamed organisation"
        end

        organisation = Organisation.find_by(name: organisation_name.strip)

        if organisation.nil?
            organisation = Organisation.new
            organisation.name = organisation_name.strip
            organisation.description = row['description']
            organisation.email = row['contact_email']
            organisation.url = row['url']
            organisation.old_external_id = row['import_id']
        end

        organisation
    end

    def create_regular_schedule(row)

        days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']

        scheduled = RegularSchedule.create
        scheduled.opens_at = row['schedules_opens_at']
        scheduled.closes_at = row['schedules_closes_at']
        scheduled.weekday = days.find_index(row['scheduled_weekday'].downcase)
        byebug

        scheduled
    end

    def create_service_contact(row)
        contact = Contact.create
        contact.name = row['contact_name']
        contact.title = row['contact_title']
        contact.visible = row['contact_visible']
        contact.email = row['contact_email']
        contact.phone = row['contact_phone']
        
        contact
    end

    def create_service_cost(row)
        costoption = CostOption.create
        costoption.option = row['cost_option']
        costoption.amount = row['cost_amount']
        costoption.cost_type = row['cost_type']
        
        costoption
    end

    def create_taxonomy(taxonomy_name)
        taxonomy = Taxonomy.create
        taxonomy.name = taxonomy_name
        
        taxonomy
    end

    def create_suitability(suitability_name)
        suitability = Suitability.create
        suitability.name = suitability_name
        
        suitability
    end

    def create_send_need(support_name)
        sendNeed = SendNeed.create
        sendNeed.name = support_name
        
        sendNeed
    end

    def create_accessibilities(row)
        accessibilities_array = row['location_accessibilities'].split(';')
        accessibilities_array.each { |accessibilities_name|
            begin
                existing_accessibility = Accessibility.find_by(name: accessibilities_name.strip)

                if existing_accessibility.nil?
                    accessibility = Accessibility.create
                    accessibility.name = accessibilities_name.strip
    
                    accessibility.locations << create_location(row)
                end
                
            rescue StandardError => e 
                raise "An error occurred while importing Accessibility in row #{row['import_id']} failed to save: #{accessibility.errors.messages}"
            end
        }
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

    def create_report_postcode(row)
        reportPostCode = ReportPostcode.new
        reportPostCode.postcode = row['location_postcode']

        rescue StandardError => e 
            raise "An error occurred while importing ReportPostcode in row #{row['import_id']} failed to save: #{reportPostCode.errors.messages}"
     end

     def create_link(row)
        link = Link.create
        link.label = row['links_label']
        link.url = row['links_url']

        link
    end

    def create_notes(row)
        note = Note.create
        note.body = row['notes']
        note.user = User.where(admin: true).first

        note
    end

    def create_custom_field(key, value)
        service_meta = ServiceMeta.create
        service_meta.key = key
        service_meta.value = value

        service_meta
    end
end