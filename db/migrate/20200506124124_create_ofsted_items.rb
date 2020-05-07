class CreateOfstedItems < ActiveRecord::Migration[6.0]
  def change
    create_table :ofsted_items do |t|
      t.string :provider_name
      t.string :setting_name
      t.integer :reference_number
      t.string :provision_type
      t.string :secondary_provision_type
      t.string :registration_status
      t.string :special_consideration
      t.date :registration_date
      t.date :last_change_date
      t.string :link_to_ofsted_report
      t.string :setting_address_1
      t.string :setting_address_2
      t.string :setting_villagetown
      t.string :setting_town
      t.string :setting_county
      t.string :setting_postcode
      t.string :setting_telephone
      t.string :setting_fax
      t.string :setting_email
      t.string :location_ward
      t.string :location_planning
      t.string :prov_address_1
      t.string :prov_address_2
      t.string :prov_villagetown
      t.string :prov_town
      t.string :prov_county
      t.string :prov_postcode
      t.string :prov_telephone
      t.string :prov_mobile
      t.string :prov_work_telephone
      t.string :prov_fax
      t.string :prov_email
      t.string :prov_consent_withheld
      t.string :rp_reference_number
      t.string :related_rpps
      t.string :registration_status_history
      t.string :child_services_register
      t.string :certificate_condition
      t.text :childcare_period, array: true
      t.string :childcare_age
      t.string :inspection
      t.string :notice_history
      t.string :welfare_notice_history
      t.string :linked_registration
      t.datetime :lastupdated
    end
  end
end
