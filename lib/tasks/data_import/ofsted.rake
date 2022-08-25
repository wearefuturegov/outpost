namespace :import do
  namespace :ofsted do

    desc 'Set Open Objects external ids'
    task :set_open_objects_external_ids => :environment do
      ofsted_file = File.open('lib/seeds/ofsted.csv', "r:ISO-8859-1")
      open_objects_ofsted_csv = CSV.parse(ofsted_file, headers: true)

      open_objects_ofsted_csv.each do |row|
        ofsted_item = OfstedItem.where(reference_number: row['reference_number']).first
        if ofsted_item
          ofsted_item.open_objects_external_id = row['externalid']
          unless ofsted_item.save
            puts "Failed to update OO externalID #{ofsted_item.open_objects_external_id}"
          end
        end
      end
    end

    desc 'Link new Ofsted items to services'
    task :link_new_items_to_services => :environment do
      ofsted_extras_file = File.open('lib/seeds/ofsted_extras.csv', "r:ISO-8859-1")
      ofsted_extras_csv = CSV.parse(ofsted_extras_file, headers: true)

      oo_services_file = File.open('lib/seeds/geo.csv', "r:utf-8")
      oo_services_csv = CSV.parse(oo_services_file, headers: true)

      ofsted_extras_csv.each_with_index do |row, line|
        new_ofsted_csv_item = row
        puts "Line #{line}"
        oo_services = oo_services_csv.select{|oo_service| oo_service['registered_setting_identifier'] == new_ofsted_csv_item['externalid']}
        puts "More than one" if oo_services.count > 1
        if oo_services.empty?
          if new_ofsted_csv_item['provision_type'] != "Registered Person Provision"
            puts "Not RPP"
          end
          puts "No service found in OO export for ofsted item with external ID #{new_ofsted_csv_item['externalid']} and reference number #{new_ofsted_csv_item['reference_number']}"
        else
          oo_services.each do |oo_service|
            puts "Open objects service: #{oo_service["title"]}"

            service = Service.where(old_open_objects_external_id: oo_service['externalid']).first
            if service.present?
              puts "Outpost service: #{service.name}"

              ofsted_item = OfstedItem.where(reference_number: new_ofsted_csv_item['reference_number']).first

              if ofsted_item.present?
                puts "Ofsted item: #{ofsted_item.provider_name}"
                puts "Linking Ofsted item: #{ofsted_item.id} to service #{service.id}"
                service.ofsted_item_id = ofsted_item.id
                service.skip_mongo_callbacks = true
                if service.save(touch: false)
                  puts "linked service #{service.id} to Ofsted item: #{ofsted_item.id}"
                else
                  puts "Failed to link service #{service.id} to Ofsted item: #{ofsted_item.id}, errors: #{service.errors.messages}"
                end
              else
                puts "No Outpost Ofsted item found for #{new_ofsted_csv_item['reference_number']}"
              end
            else
              puts "No service found in Outpost for OO service: #{oo_service['title']}"
            end
          end
        end
      end
    end

    desc 'Reset all the Ofsted item statuses'
    task :set_status_and_discarded_at_nil => :environment do
      OfstedItem.all.each do |ofsted_item|
        ofsted_item.status = nil
        ofsted_item.discarded_at = nil
        ofsted_item.save
      end
    end

  end
end
