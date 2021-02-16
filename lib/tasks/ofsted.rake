namespace :ofsted do

  task :create_initial_items => :environment do
    response = HTTParty.get("#{ENV["OFSTED_FEED_API_ENDPOINT"]}?token=#{ENV["OFSTED_API_KEY"]}")
    items = JSON.parse(response.body)["OfstedChildcareRegisterLocalAuthorityExtract"]["Registration"]

    items.each do |item|
      ofsted_item = OfstedItem.new(ofsted_item_params(item))

      if ofsted_item.save
        puts "Created ofsted item #{ofsted_item.provider_name}"
      else
        puts "Failed to create ofsted item #{ofsted_item.provider_name}: #{ofsted_item.errors.messages}"
      end
    end
  end

  task :set_open_objects_external_ids => :environment do
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
    response = HTTParty.get("#{ENV["OFSTED_FEED_API_ENDPOINT"]}?token=#{ENV["OFSTED_API_KEY"]}")
    items = JSON.parse(response.body)["OfstedChildcareRegisterLocalAuthorityExtract"]["Registration"]

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
    provider_name: item["Provider"]["ProviderName"],
    setting_name: item["Setting"]["SettingName"],
    reference_number: item["ReferenceNumber"],
    provision_type: item["ProvisionType"],
    secondary_provision_type: item["SecondaryProvisionType"],
    registration_status: item["RegistrationStatus"],
    special_consideration: item["SpecialConsiderations"],
    registration_date: item["RegistrationDate"],
    last_change_date:item["LastChangeDate"],
    # link_to_ofsted_report:
    setting_address_1: item["Setting"]["SettingAddress"]["AddressLine1"],
    setting_address_2: item["Setting"]["SettingAddress"]["AddressLine2"],
    # setting_villagetown:
    setting_town: item["Setting"]["SettingAddress"]["Town"],
    setting_county: item["Setting"]["SettingAddress"]["County"],
    setting_postcode: item["Setting"]["SettingAddress"]["Postcode"],
    setting_telephone: item["Setting"]["SettingContact"]["TelephoneNumber"],
    # setting_fax:
    setting_email: item["Setting"]["SettingContact"]["EmailAddress"],
    # location_ward:
    # location_planning:
    prov_address_1: item["Provider"]["ProviderAddress"]["AddressLine1"],
    prov_address_2: item["Provider"]["ProviderAddress"]["AddressLine2"],
    # prov_villagetown:
    prov_town: item["Provider"]["ProviderAddress"]["Town"],
    prov_county: item["Provider"]["ProviderAddress"]["County"],
    prov_postcode: item["Provider"]["ProviderAddress"]["Postcode"],
    prov_telephone: item["Provider"]["ProviderAddress"]["TelephoneNumber"],
    prov_mobile: item["Provider"]["ProviderAddress"]["MobileNumber"],
    prov_work_telephone: item["Provider"]["ProviderAddress"]["WorkTelephoneNumber"],
    # prov_fax:
    prov_email: item["Provider"]["ProviderAddress"]["EmailAddress"],
    # prov_consent_withheld:
    rp_reference_number: item["RPReferenceNumber"],
    # related_rpps:
    # registration_status_history:
    # child_services_register:
    # childcare_period:
    # childcare_age:
    # inspection:
    # notice_history:
    # welfare_notice_history:
    lastupdated: item["LastChangeDate"]
  }
end