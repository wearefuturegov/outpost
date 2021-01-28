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
        registration_date: i["RegistrationDate"]
        # last_change_date:
        # link_to_ofsted_report:
        # setting_address_1:
        # setting_address_2:
        # setting_villagetown:
        # setting_town:
        # setting_county:
        # setting_postcode:
        # setting_telephone:
        # setting_fax:
        # setting_email:
        # location_ward:
        # location_planning:
        # prov_address_1:
        # prov_address_2:
        # prov_villagetown:
        # prov_town:
        # prov_county:
        # prov_postcode:
        # prov_telephone:
        # prov_mobile:
        # prov_work_telephone:
        # prov_fax:
        # prov_email:
        # prov_consent_withheld:
        # rp_reference_number:
        # related_rpps:
        # registration_status_history:
        # child_services_register:
        # childcare_period:
        # childcare_age:
        # inspection:
        # notice_history:
        # welfare_notice_history:
        # lastupdated:
      }
end

print output