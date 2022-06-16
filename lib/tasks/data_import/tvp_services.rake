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
                organisation_id = Organisations(row)
                service_id = Services(row, organisation_id)
                Service_Contact(row, service_id)
                Service_Cost(row, service_id)
                Taxonomy(row, service_id)
                Suitability(row)
                ReportPostcode(row)
                OfstedItems(row)
            end

            end_time = Time.now
            puts "Took #{(end_time - start_time)/60} minutes"
        end

        # 
        # Rake::Task['organisations:import'].invoke(csv_parser)

        # puts 'Services data importing'
        # Rake::Task['services:import'].invoke(csv_parser)
        
        rescue StandardError => e 
            puts "Import aborted => : #{e.message}" 
    end

    def Organisations(row)
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
        organisation.save!

        organisation.id
    end

    def Services(row, organisation_id)
        service = Service.new
        service.organisation_id = organisation_id
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

        service.id
    end

    def Service_Contact(row, service_id)
        unless row['contact_name'].blank? && row['contact_email'].blank? && row['contact_phone'].blank?
            contact = Contact.new
            contact.service_id = service_id
            contact.name = row['contact_name']
            contact.title = row['contact_title']
            contact.visible = row['contact_visible']
            contact.email = row['contact_email']
            contact.phone = row['contact_phone']
            contact.save!
        end
    end

    def Service_Cost(row, service_id)
        unless row['cost_amount'].blank?
            costoption = CostOption.new
            costoption.service_id = service_id
            costoption.option = row['cost_option']
            costoption.amount = row['cost_amount']
            costoption.cost_type = row['cost_type']
            costoption.save!
        end
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

    def Taxonomy(row, service_id)
        if !row['service_taxonomies'].nil?
            service_taxonomies_array = row['service_taxonomies'].split(';')
            service_taxonomies_array.each { |taxonomy_name|
                taxonomy = Taxonomy.new
                taxonomy.name = taxonomy_name
                taxonomy.save!
                
                serviceTaxonomy = ServiceTaxonomy.new
                serviceTaxonomy.taxonomy_id = taxonomy.id
                serviceTaxonomy.service_id = service_id
                serviceTaxonomy.save!
            }
        end
    end

    def ReportPostcode(row)
        reportPostCode = ReportPostcode.new
        reportPostCode.postcode = row['location_postcode']
        reportPostCode.save!
    end

    def OfstedItems(row)

    end
end