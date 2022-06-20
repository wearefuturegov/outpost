require 'csv'
namespace :tvp_services do
    task :import => :environment do
        start_time = Time.now

        #file_path = Rails.root.join('lib', 'tasks', 'data_import', 'data-import--with-sample-data.csv')
        #file_path = Rails.root.join('lib', 'seeds', 'TVP services for import - Service Data.csv')
        file_path = Rails.root.join('lib', 'seeds', 'data-for-import.csv')
        file = File.open(file_path, "r:ISO-8859-1")
        csv_parser = CSV.parse(file, headers: true)

        puts 'Checkig for duplicate names'
        #remove nil from array
        name_array = csv_parser['name']

        compact_name_array = name_array.compact

        #find duplicated value in column Name
        duplicated_array = name_array.compact.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)

        if (duplicated_array.length > 0)
            raise "There is duplicate names in csv file: #{duplicated_array}"
        end

        ActiveRecord::Base.transaction do 
            csv_parser.each.with_index do |row, index|
                Service(row)
                Suitability(row)
                ReportPostcode(row)
                Accessibilities(row)
            end

            end_time = Time.now
            puts "Took #{(end_time - start_time)/60} minutes"
        end

        rescue StandardError => e 
            puts "Import aborted => : #{e.message}" 
    end

    def Service(row)
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
        service.organisation = Organisation(row)
        unless row['contact_name'].blank? && row['contact_email'].blank? && row['contact_phone'].blank?
            service.contacts << Service_Contact(row)
        end
        unless row['cost_amount'].blank?
            service.cost_options << Service_Cost(row)
        end
        if !row['service_taxonomies'].nil?
            service_taxonomies_array = row['service_taxonomies'].split(';')
            service_taxonomies_array.each { |taxonomy_name|
                service.taxonomies << Taxonomy(taxonomy_name)
            }
        end

        unless row['schedules_opens_at'].blank? && row['schedules_closes_at'].blank? && row['scheduled_weekday'].blank?
            service.regular_schedules << RegularSchedule(row)
        end

        unless row['location_postcode'].blank?
            service.locations << Location(row)
        end

        service.save!
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
        organisation.old_external_id = row['import_id']

        organisation
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
                suitability = Suitability.new
                suitability.name = suitability_name
                suitability.save!
            }
        end
    end

    def ReportPostcode(row)
        reportPostCode = ReportPostcode.new
        reportPostCode.postcode = row['location_postcode']
        reportPostCode.save!
    end

    def Accessibilities(row)
        if !row['location_accessibilities'].nil?
            byebug
            accessibilities_array = row['location_accessibilities'].split(';')
            accessibilities_array.each { |accessibilities_name|
                accessibility = Accessibility.new
                accessibility.name = accessibilities_name

                accessibility.locations << Location(row)
               
                accessibility.save!
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
end