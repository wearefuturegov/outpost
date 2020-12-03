namespace :ofsted do

  task :create_initial_items => :environment do
    response = HTTParty.get("#{ENV["OFSTED_FEED_API_ENDPOINT"]}?api_key=#{ENV["OFSTED_API_KEY"]}")
    items = JSON.parse(response.body)

    items.each do |item|
      ofsted_item = OfstedItem.new(ofsted_item_params(item))

      if ofsted_item.save
        puts "Created ofsted item #{ofsted_item.provider_name}"
      else
        puts "Failed to create ofsted item #{ofsted_item.provider_name}: #{ofsted_item.errors.messages}"
      end
    end
  end

  task :set_open_objects_external_ids do
    ofsted_file = File.open('lib/seeds/ofsted.csv', "r:ISO-8859-1")
    open_objects_ofsted_csv = CSV.parse(ofsted_file, headers: true)

    open_objects_ofsted_csv.each do |row|
      ofsted_item = OfstedItem.where(reference_number: row['reference_number']).first
      if ofsted_item
        ofsted_item.open_objects_external_id = row['externalid']
        if ofsted_item.save
          puts "Set ofsted item OO externalID #{ofsted_item.open_objects_external_id}"
        else
          puts "Failed to update OO externalID #{ofsted_item.open_objects_external_id}"
        end
      end
    end
  end

  task :set_status_and_discarded_at_nil => :environment do
    OfstedItem.all.each do |ofsted_item|
      ofsted_item.status = nil
      ofsted_item.discarded_at = nil
      ofsted_item.save
    end
  end

  # To be scheduled
  task :update_items => :environment do
    response = HTTParty.get("#{ENV["OFSTED_FEED_API_ENDPOINT"]}?api_key=#{ENV["OFSTED_API_KEY"]}")
    items = JSON.parse(response.body)

    items.each do |item| # Iterate through iterms returend from Ofsted feed API
      ofsted_item = OfstedItem.where(reference_number: item["reference_number"]).first # Check if ofsted item already exists

      if ofsted_item
        ofsted_item.assign_attributes(ofsted_item_params(item)) # Prepare for update

        if ofsted_item.changed?
          ofsted_item.status = "changed"
          if ofsted_item.save # Save
            puts "Updated ofsted item #{ofsted_item.provider_name}"
          else
            puts "Failed to update ofsted item #{ofsted_item.provider_name}"
          end
        end

      else # if no ofsted item found, create new one
        ofsted_item = OfstedItem.new(ofsted_item_params(item))
        ofsted_item.status = "new"

        if ofsted_item.save
          puts "Created ofsted item #{ofsted_item.provider_name}"
        else
          puts "Failed to create ofsted item #{ofsted_item.provider_name}"
        end

      end

    end

    OfstedItem.all.each do |ofsted_item| # check for deleted
      next if items.select { |item| item["reference_number"] == ofsted_item.reference_number }.present? # Dont archive if still in feed
      next if (ofsted_item.discarded_at != nil) && (ofsted_item.status == 'deleted') # Don't archive if already archived.
      ofsted_item.status = "deleted"
      ofsted_item.discarded_at = Time.now
      if ofsted_item.save
        puts "Set ofsted item status to deleted"
      else
        puts "Failed to update ofsted item"
      end
    end

  end
end

# def check_for_new(items)
#   items.each do |item| # Iterate through iterms returend from Ofsted feed API
#     ofsted_item = OfstedItem.where(reference_number: item["reference_number"]).first # Check if ofsted item already exists
#     unless items
#   end
# end


def ofsted_item_params item
  {
    provider_name: item["provider_name"],
    setting_name: item["setting_name"],
    reference_number: item["reference_number"],# to_i?
    provision_type: item["provision_type"],
    secondary_provision_type: item["secondary_provision_type"],
    registration_status: item["registration_status"],
    special_consideration: item["special_consideration"],
    registration_date: item["registration_date"],# date
    last_change_date: item["last_change_date"],# date
    link_to_ofsted_report: item["link_to_ofsted_report"],
    setting_address_1: item["setting_address_1"],
    setting_address_2: item["setting_address_2"],
    setting_villagetown: item["setting_villagetown"],
    setting_town: item["setting_town"],
    setting_county: item["setting_county"],
    setting_postcode: item["setting_postcode"],
    setting_telephone: item["setting_telephone"],
    setting_fax: item["setting_fax"],
    setting_email: item["setting_email"],
    location_ward: item["location_ward"],
    location_planning: item["location_planning"],
    prov_address_1: item["prov_address_1"],
    prov_address_2: item["prov_address_2"],
    prov_villagetown: item["prov_villagetown"],
    prov_town: item["prov_town"],
    prov_county: item["prov_county"],
    prov_postcode: item["prov_postcode"],
    prov_telephone: item["prov_telephone"],
    prov_mobile: item["prov_mobile"],
    prov_work_telephone: item["prov_work_telephone"],
    prov_fax: item["prov_fax"],
    prov_email: item["prov_email"],
    prov_consent_withheld: item["prov_consent_withheld"],
    rp_reference_number: item["rp_reference_number"],
    related_rpps: item["related_rpps"],
    registration_status_history: item["registration_status_history"],
    child_services_register: item["child_services_register"],
    certificate_condition: item["certificate_condition"],
    childcare_period: item["childcare_period"], #to_a?
    childcare_age: item["childcare_age"],
    inspection: item["inspection"],
    notice_history: item["notice_history"],
    welfare_notice_history: item["welfare_notice_history"],
    linked_registration: item["linked_registration"],
    lastupdated: item["lastupdated"] #datetime
  }
end