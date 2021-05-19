namespace :services do

  # For every service that's linked to an Ofsted item, takes the setting address
  # fields from the item in the Ofsted feed, and maps them to custom fields where
  # they can be managed and maintained by admins.
  desc 'Map Ofsted setting addresses to service meta (custom fields)'
  task :map_ofsted_setting_addresses_to_custom_fields => :environment do

    META_KEY_MAP = {
      setting_address_1: 'Setting Address, Street address 1',
      setting_address_2: 'Setting Address, Street address 2',
      setting_town: 'Setting Address, Town',
      setting_county: 'Setting Address, County',
      setting_postcode: 'Setting Address, Postcode'
    }

    puts 'Finding services linked to Ofsted items...'
    Service.where.not(ofsted_item: nil).find_each do |service|
      META_KEY_MAP.each do |field, key|
        meta = service.meta.find_or_initialize_by(key: key)

        if meta.value.present?
          puts "Meta '#{key}' already exists for service ##{service.id}, skipping"
          next
        end

        meta.value = service.ofsted_item[field]
        meta.save!
      end
    end

    puts 'Done!'
  end
end
