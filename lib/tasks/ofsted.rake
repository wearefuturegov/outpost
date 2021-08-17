namespace :ofsted do

  # Scheduled every morning
  task :update_items => :environment do
    response = HTTParty.get("#{ENV["OFSTED_FEED_API_ENDPOINT"]}?token=#{ENV["OFSTED_API_KEY"]}")
    items = JSON.parse(response.body)["OfstedChildcareRegisterLocalAuthorityExtract"]["Registration"]

    items.each do |item| # Iterate through iterms returend from Ofsted feed API
      ofsted_item = OfstedItem.where(reference_number: item["ReferenceNumber"]).first # Check if ofsted item already exists

      if ofsted_item
        ofsted_item.assign_attributes(ofsted_item_params(item)) # Prepare for update

        if ofsted_item.changed?
          ofsted_item.status = "changed" unless (ofsted_item.status == "restored") ||  (ofsted_item.status == "new") # maintain restored or new status until acknowledged

          if ofsted_item.discarded_at.present? # Item has reappeard in feed
            ofsted_item.discarded_at = nil
            ofsted_item.status = "restored"
          end

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
      next if items.select { |item| item["ReferenceNumber"] == ofsted_item.reference_number }.present? # Dont archive if still in feed
      next if (ofsted_item.discarded_at != nil) # Don't archive if already archived.
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

def ofsted_item_params item
  {
    provider_name: item.dig("Provider", "ProviderName"),
    setting_name: item.dig("Setting", "SettingName"),
    reference_number: item.dig("ReferenceNumber"),
    provision_type: item.dig("ProvisionType"),
    secondary_provision_type: item.dig("SecondaryProvisionType"),
    registration_status: item.dig("RegistrationStatus"),
    special_consideration: item.dig("SpecialConsiderations"),
    registration_date: item.dig("RegistrationDate"),
    last_change_date:item.dig("LastChangeDate"),
    setting_address_1: item.dig("Setting", "SettingAddress", "AddressLine1"),
    setting_address_2: item.dig("Setting", "SettingAddress", "AddressLine2"),
    setting_town: item.dig("Setting", "SettingAddress", "Town"),
    setting_county: item.dig("Setting", "SettingAddress", "County"),
    setting_postcode: item.dig("Setting", "SettingAddress", "Postcode"),
    setting_telephone: item.dig("Setting", "SettingContact", "TelephoneNumber"),
    setting_fax: item.dig("Setting", "SettingContact", "FaxNumber"),
    setting_email: item.dig("Setting", "SettingContact", "EmailAddress"),
    prov_address_1: item.dig("Provider", "ProviderAddress", "AddressLine1"),
    prov_address_2: item.dig("Provider", "ProviderAddress", "AddressLine2"),
    prov_town: item.dig("Provider", "ProviderAddress", "Town"),
    prov_county: item.dig("Provider", "ProviderAddress", "County"),
    prov_postcode: item.dig("Provider", "ProviderAddress", "Postcode"),
    prov_telephone: item.dig("Provider", "ProviderContact", "TelephoneNumber"),
    prov_mobile: item.dig("Provider", "ProviderContact", "MobileNumber"),
    prov_work_telephone: item.dig("Provider", "ProviderContact", "WorkTelephoneNumber"),
    prov_fax: item.dig("Provider", "ProviderContact", "FaxNumber"),
    prov_email: item.dig("Provider", "ProviderContact", "EmailAddress"),
    rp_reference_number: item.dig("RPReferenceNumber"),
    registration_status_history:  Array.wrap(item.dig("RegistrationStatusHistoryList", "RegistrationStatusHistory")),
    child_services_register: Array.wrap(item.dig("ChildServicesRegisterList", "ChildServicesRegister")),
    childcare_period: Array.wrap(item.dig("ChildcarePeriodList", "ChildcarePeriod")),
    childcare_age: Array.wrap(item.dig("ChildcareAgeList", "ChildcareAge")),
    inspection: Array.wrap(item.dig("InspectionList", "Inspection")),
    notice_history: Array.wrap(item.dig("NoticeHistoryList", "NoticeHistory")),
    welfare_notice_history: Array.wrap(item.dig("WelfareNoticeHistoryList", "WelfareNoticeHistory"))
  }
end