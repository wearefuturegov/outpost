require "JSON"

file = File.open('lib/seeds/ofsted.json', "r:ISO-8859-1")
data = JSON.load file
items = data["OfstedChildcareRegisterLocalAuthorityExtract"]["Registration"]

output = items.slice(0, 1).map do |i|
    {
        provider_name: i["Provider"]["ProviderName"],
        setting_name: i["Setting"]["SettingName"],
        reference_number: i["ReferenceNumber"],
        provision_type: i["ProvisionType"],
        secondary_provision_type: i["SecondaryProvisionType"],
        registration_status: i["RegistrationStatus"],
        special_consideration: i["SpecialConsiderations"],
        registration_date: i["RegistrationDate"],
        last_change_date:i["LastChangeDate"],
        # link_to_ofsted_report:
        setting_address_1: i["Setting"]["SettingAddress"]["AddressLine1"],
        setting_address_2: i["Setting"]["SettingAddress"]["AddressLine2"],
        # setting_villagetown:
        setting_town: i["Setting"]["SettingAddress"]["Town"],
        setting_county: i["Setting"]["SettingAddress"]["County"],
        setting_postcode: i["Setting"]["SettingAddress"]["Postcode"],
        setting_telephone: i["Setting"]["SettingContact"]["TelephoneNumber"],
        # setting_fax:
        setting_email: i["Setting"]["SettingContact"]["EmailAddress"],
        # location_ward:
        # location_planning:
        prov_address_1: i["Provider"]["ProviderAddress"]["AddressLine1"],
        prov_address_2: i["Provider"]["ProviderAddress"]["AddressLine2"],
        # prov_villagetown:
        prov_town: i["Provider"]["ProviderAddress"]["Town"],
        prov_county: i["Provider"]["ProviderAddress"]["County"],
        prov_postcode: i["Provider"]["ProviderAddress"]["Postcode"],
        prov_telephone: i["Provider"]["ProviderAddress"]["TelephoneNumber"],
        prov_mobile: i["Provider"]["ProviderAddress"]["MobileNumber"],
        prov_work_telephone: i["Provider"]["ProviderAddress"]["WorkTelephoneNumber"],
        # prov_fax:
        prov_email: i["Provider"]["ProviderAddress"]["EmailAddress"],
        # prov_consent_withheld:
        rp_reference_number: i["RPReferenceNumber"],
        # related_rpps:
        # registration_status_history:
        # child_services_register:
        # childcare_period:
        # childcare_age:
        # inspection:
        # notice_history:
        # welfare_notice_history:
        lastupdated: i["LastChangeDate"]
      }
end

print output