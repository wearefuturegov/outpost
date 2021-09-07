require 'csv'
namespace :bod do
  namespace :services do

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

    task :import => :environment do
      services_file = File.open('lib/seeds/bod/services.csv', "r:utf-8")
      services_csv = CSV.parse(services_file, headers: true)

      services_csv.each.with_index do |row, line|
        organisation = Organisation.where('lower(name) = ?', row["BFIS Parent"]&.strip&.downcase).first

        if organisation.present? && !organisation.created_at.today?
          puts "Organissation already exists from BFIS: #{organisation.name}, was created at #{organisation.created_at}"
        elsif organisation.present? && organisation.created_at.today?
          puts "Organisation already created on this import: #{organisation.name}, was created at #{organisation.created_at}"
        else
          organisation = Organisation.new(name: row["BFIS Parent"]&.strip)
          organisation.skip_mongo_callbacks = true
          puts "Organisation #{organisation.name} failed to save, error message: #{organisation.errors.messages}" unless organisation.save
        end

        if row["UPDATE EMAIL"].present?
          existing_user = User.where(email: row["UPDATE EMAIL"]&.strip).first

          if existing_user.present?
            puts "Existing user #{existing_user.email} in different org #{existing_user.organisation.id} (new org: #{organisation.id})" if existing_user.organisation != organisation
          else
            new_user = User.new(email: row["UPDATE EMAIL"], organisation: organisation)
            new_user.skip_name_validation = true
            new_user.password = "A9b#{SecureRandom.hex(8)}1yZ"
            unless new_user.save
              puts "User #{new_user.email} failed to save: #{new_user.errors.messages}"
            end
          end
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

        service.update(directories: service.directories << "Buckinghamshire Online Directory")

        if service.save
          # CUSTOM FIELDS
          if row["Volunteer DBS check"].present?
            service_meta = service.meta.new(key: "Volunteer DBS check", value: row["Volunteer DBS check"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Safeguarding"].present?
            service_meta = service.meta.new(key: "Safeguarding", value: row["Safeguarding"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Health and safety?"].present?
            service_meta = service.meta.new(key: "Health and safety?", value: row["Health and safety?"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Insurance?"].present?
            service_meta = service.meta.new(key: "Insurance?", value: row["Insurance?"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["confid data protect"].present?
            service_meta = service.meta.new(key: "Confid data protect", value: row["confid data protect"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["equality diversity"].present?
            service_meta = service.meta.new(key: "Equality diversity", value: row["equality diversity"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["PCN"].present?
            service_meta = service.meta.new(key: "Primary Care Network", value: row["PCN"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Community Board"].present?
            service_meta = service.meta.new(key: "Community board for Buckinghamshire Council", value: row["Community Board"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["GDPR Permission "].present?
            service_meta = service.meta.new(key: "GDPR Permission", value: row["GDPR Permission "])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["GDPR Authorised By"].present?
            service_meta = service.meta.new(key: "GDPR Authorised By", value: row["GDPR Authorised By"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["GDPR Permission Date"].present?
            service_meta = service.meta.new(key: "GDPR Permission Date", value: row["GDPR Permission Date"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Review date"].present?
            service_meta = service.meta.new(key: "Review date", value: row["Review date"])
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
        else
          puts "Service #{service.name} failed to save, error message: #{service.errors.messages}"
        end

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

        # add accessibility info to locations
        accessibility = eval(row['Accessibility'])
        if accessibility.present?
          accessibility_mapping = {
            "building wheelchair access" => "Wheelchair accessible entrance",
            "on-site parking" => "Car parking",
            "nearby bus stop" => "Bus stop nearby", # new
            "hearing induction loop" => "Hearing loop",
            "wc wheelchair access" => "Accessible toilet facilities",
            "building lift" => "Building has lift" # new
          }
          options = accessibility
          options.each do |option|
            location.accessibilities << Accessibility.find_or_initialize_by({name: accessibility_mapping[option].downcase.capitalize}) if accessibility_mapping[option].present?
          end
        end

        suitabilities = eval(row['Suitable for people with...'])
        suitabilities_mapping = {
          "older people" => "Older people",
          "mental health/acquired brain injury" => "Mental health/acquired brain injury",
          "physical difficulty" => "Physical Disabilities",
          "visual and/or hearing impediment" => "Visual and/or hearing impediment",
          "learning disability" => "Learning difficulties",
          "autism" => "Autism",
          "dementia" => "Dementia"
        }
        if suitabilities.present?
          suitabilities.each do |suitability|
            service.suitabilities << Suitability.find_or_initialize_by({name: suitabilities_mapping[suitability].downcase.capitalize}) if suitabilities_mapping[suitability].present?
          end
        end
        puts "Location #{location.name} failed to save, error message: #{location.errors.messages}" unless location.save
      end
    end
  
    task :apply_bfis_directory_to_current => :environment do
      set_existing_services_as_bfis
    end

    task :import_opening_hours => [ :environment ] do
      include RegularScheduleHelper

      csv_file = File.open('lib/seeds/bod/opening_hours.csv', "r:utf-8")
      opening_hours_csv = CSV.parse(csv_file, headers: true)

      opening_hours_csv.each.with_index do |row, line|
        #next if row["Opening Times List_Start Time"] == "CLOSED"
        if row["day"].present? && row["opens at"].present? && row["closes at"].present?
          service = Service.where(old_open_objects_external_id: row["asset ID"]).first
          if service
            opening_time = row["opens at"].sub(".", ":")
            closing_time = row["closes at"].sub(".", ":")

            opening_time = opening_time.insert(2, ':') unless opening_time.include?(":")
            closing_time = closing_time.insert(2, ':') unless closing_time.include?(":")

            opening_time = opening_time.to_time.strftime("%H:%M")
            closing_time = closing_time.to_time.strftime("%H:%M")

            if closing_time < opening_time # probs using 12 hour clock
              closing_time = DateTime.parse("#{closing_time}pm").strftime("%H:%M")
            end

            rs = service.regular_schedules.new(
              opens_at: opening_time,
              closes_at: closing_time,
              weekday: weekdays.select{ |w| w[:label] === row["day"].split(" ")[0]}.first[:value]
            )
            unless rs.save
              puts "Reg schedule failed #{rs.errors.messages} for service #{service.id}"
            end
          end
        end
      end
    end

    task :update_directories_as_text_field => [ :environment ] do
      Service.all.each do |s|
        s.skip_mongo_callbacks = true
        s.directories_as_text = s.directories&.sort&.join(", ") # make sure directories always in same order
        s.save
      end
    end
  end
end

def set_existing_services_as_bfis
  puts "Applying BFIS directory tag to existing services"
  Service.all.each do |service|
    service.skip_mongo_callbacks = true
    service.update(directories: service.directories << "Family Information Service")
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