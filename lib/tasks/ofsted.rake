namespace :ofsted do

  # To be run once initially
  task :set_reference_ids_on_existing_childcare_records => :environment  do
    ofsted_file = File.open('lib/seeds/ofsted.csv', "r:ISO-8859-1")
    open_objects_ofsted_csv = CSV.parse(ofsted_file, headers: true)

    open_objects_ofsted_csv.each do |row|

      #ofsted_item = OfstedItem.new

      matching_ofsted_services = OfstedService.where(old_ofsted_external_id: row['externalid'])
      matching_ofsted_services.each do |os|

        os.ofsted_reference_number = row['reference_number']
        os.save
        puts "Setting #{os.name} reference number as: #{row['reference_number']}"
        #ofsted_service.save
      end
    end
  end

  # To be scheduled
  task :update_items => :environment do
    response = HTTParty.get("https://bucks-ofsted-feed.herokuapp.com?api_key=#{ENV["OFSTED_API_KEY"]}")
    items = JSON.parse(response.body)

    # check_for_new(items)
    # check_for_updates(items)
    # check_for_deleted(items)

    items.each do |item| # Iterate through iterms returend from Ofsted feed API
      ofsted_item = OfstedItem.where(reference_number: item["reference_number"]).first # Check if ofsted item already exists

      if ofsted_item # If so, find childcafe related services
        ofsted_services = OfstedService.where(ofsted_reference_number: item["reference_number"])

        ofsted_item.assign_attributes(ofsted_item_params(item)) # Prepare for update

        if ofsted_item.registration_status_changed?
          if ofsted_item.registration_status == "Cancelled"
            ofsted_services.each do |ofsted_service|
              ofsted_service.discard
              ofsted_service.snapshot_action = "ofsted_cancelled"
              ofsted_service.approved = false
              if ofsted_service.save
                puts "Updated childcare service #{ofsted_service.name}"
              else
                puts "Failed to update childcare service #{ofsted_service.name}"
              end
            end
          end
        end

        if ofsted_item.setting_name_changed? # If changed, update corresponding service

          ofsted_services.each do |ofsted_service| # Could be multiple childcare services

            ofsted_service.assign_attributes(ofsted_service_params(item))
            ofsted_service.snapshot_action = "ofsted_update"

            if ofsted_service.save
              puts "Updated childcare service #{ofsted_service.name}"
            else
              puts "Failed to update childcare service #{ofsted_service.name}"
            end
          end

        end

        if ofsted_item.save # Save
          puts "Updated ofsted item #{ofsted_item.provider_name}"
        else
          puts "Failed to update ofsted item #{ofsted_item.provider_name}"
        end

      else # if no ofsted item found, create new one
        ofsted_item = OfstedItem.new(ofsted_item_params(item))
        if ofsted_item.save
          puts "Created ofsted item #{ofsted_item.provider_name}"
        else
          puts "Failed to create ofsted item #{ofsted_item.provider_name}"
        end

        ofsted_services = OfstedService.where(ofsted_reference_number: item["reference_number"])
        if ofsted_services.size > 0 # Service already exists for this ofsted record
          puts "Childcare service already exists for this ofsted item"
        else
          user = User.where(email: item["prov_email"]).first # check if user already exists with provider email

          if user # use existing org and user if so
            puts "User #{user.email} already exists"
            organisation = user.organisation
            puts "Organisation: #{organisation.try(:name)}"
          else # ortherwise create new org and user
            organisation = Organisation.new
            organisation.save

            user = User.new # Create new user otherwise
            user.email = item["prov_email"]
            user.first_name = item["provider_name"].split.first
            user.last_name = item["provider_name"].split.last
            user.password = "A9b#{SecureRandom.hex(8)}1yZ"
            user.organisation_id = organisation.id

            if user.save
              puts "Created user: #{user.email}"
            else
              puts "Couldn't create user, errors: #{user.errors.details}"
            end
          end

          ofsted_service = organisation.services.build(ofsted_service_params(item))
          ofsted_service.snapshot_action = "ofsted_create"

          if ofsted_service.save
            puts "Created chilldcare service: #{ofsted_service.name}"
          else
            puts "Couldn't create ofsted_service"
          end
        end
      end

    end

    # OfstedItem.all.each do |ofsted_item| # check for deleted
    #   unless items.select { |item| item["reference_number"].to_i == ofsted_item.reference_number }.present?
    #     byebug
    #     ofsted_service = ofsted_item.ofsted_service
    #     ofsted_service.snapshot_action = "ofsted_delete"
    #     ofsted_service.discard
    #   end
    # end

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

def ofsted_service_params item
  {
    name: item["setting_name"],
    ofsted_reference_number: item["reference_number"],
    approved: false,
    type: 'OfstedService'
    # contact_attributes: {
    #   phone_attributes: {
    #     number: item["setting_telephone"]
    #   }
    # },
    # locations_attributes: [
    #   {
    #     name: item["setting_name"],
    #     address_1: item["setting_address_1"],
    #     city: item["setting_town"],
    #     postal_code: item["setting_postcode"]
    #   }
    # ]
  }
end