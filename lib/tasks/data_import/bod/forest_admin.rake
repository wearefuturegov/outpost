require 'csv'
namespace :forest_admin do

  MIN_AGES = {
    "young people" => nil,
    "young adults" => 18,
    "older adults" => 25
  }

  MAX_AGES = {
    "young people" => 18,
    "young adults" => 25,
    "older adults" => nil
  }
  
  task :label_bfis_records => :environment do
    set_existing_services_as_bfis
  end

  task :import => :environment do
    start_time = Time.now
    
    Rake::Task['users:create_users_from_file'].invoke

    services_file = File.open('lib/seeds/bod/services.csv', "r:utf-8")
    services_csv = CSV.parse(services_file, headers: true)

    services_csv.each.with_index do |row, line|
      organisation = Organisation.where(name: row["BFIS Parent"]).first
      if organisation.present?
        puts "Organissation already exists: #{organisation.name}, was created at #{organisation.created_at}"
      else
        organisation = Organisation.new(name: row["BFIS Parent"])
        organisation.skip_mongo_callbacks = true
        puts "Organisation #{organisation.id} failed to save, error message: #{organisation.errors.messages}" unless organisation.save
      end

      service = Service.new(
        organisation_id: organisation.id,
        name: row["Name"],
        description: row["Description"],
        url: row["URL"],
        visible: set_visibility(row["Review status"]),
        min_age: set_min_age(row["Age groups"]),
        max_age: set_max_age(row["Age groups"]),
        old_open_objects_external_id: row["Asset ID"]
      )
      service.skip_mongo_callbacks = true
      service.label_list.add("Buckinghamshire Online Directory")
      puts "Service #{service.name} failed to save, error message: #{service.errors.messages}" unless service.save

      contact = Contact.new(
        name: row["Contact name"],
        email: row["Email"],
        phone: row["Phone"]
      )
      service.contacts << contact
      puts "Contact #{contact.name} failed to save, error message: #{contact.errors.messages}" unless contact.save

      long_lat = row["Long-Lat"]&.split(",")
      location = Location.new(
        #name: row["genericField5"],
        postal_code: row["Postcode"],
        city: row["Area"],
        latitude: long_lat.kind_of?(Array) ? long_lat[1] : nil,
        longitude: long_lat.kind_of?(Array) ? long_lat[0] : nil,
        address_1: row["Venue"],
        state_province: "Buckinghamshire",
        country: 'GB'
      )
      location.skip_mongo_callbacks = true
      location.skip_postcode_validation = true
      service.locations << location
      puts "Location #{location.name} failed to save, error message: #{location.errors.messages}" unless location.save
    end

    end_time = Time.now
    puts "Took #{(end_time - start_time)/60} minutes"
  end
end

def set_existing_services_as_bfis
  puts "Applying BFIS label to existing services"
  Service.all.each do |service|
    service.label_list.add("Family Information Service")
    service.skip_mongo_callbacks = true
    service.save
  end
end

def set_visibility(review_status)
  if review_status == 'Unpublish'
    return false
  else
    return true
  end
end

def set_min_age(age_groups)
  min_ages = []
  eval(age_groups).each do |age_group|
    min_ages << MIN_AGES[age_group]
  end
  return min_ages.include?(nil) ? nil : min_ages.compact.min
end

def set_max_age(age_groups)
  max_ages = []
  eval(age_groups).each do |age_group|
    max_ages << MAX_AGES[age_group]
  end
  return max_ages.include?(nil) ? nil : max_ages.compact.max
end