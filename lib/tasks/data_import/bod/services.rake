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

    def create_user(email, org)
      if email.present? && org.present?
        new_user = User.new(email: email, organisation: org)
        new_user.skip_name_validation = true
        new_user.password = "A9b#{SecureRandom.hex(8)}1yZ"
        unless new_user.save
          puts "User #{new_user.email} failed to save: #{new_user.errors.messages}"
        end
      end
    end

    task :import => :environment do
      #services_file = File.open('lib/seeds/bod/services.csv', "r:utf-8")
      services_file = File.open('lib/seeds/bod/services.csv', "r:ISO-8859-1")
      services_csv = CSV.parse(services_file, headers: true)

      services_csv.each.with_index do |row, line|
        exisiting_service = Service.where('lower(name) = ?', row["Name"]&.strip.downcase).first

        if exisiting_service.present?
          puts "Service already exists with this name: #{exisiting_service.name}, applying BOD directory"
          exisiting_service.skip_mongo_callbacks = true
          exisiting_service.directories << Directory.where(name: "Buckinghamshire Online Directory").first
          next
        end

        existing_organisation = Organisation.where('lower(name) = ?', row["BFIS Parent"]&.strip&.downcase).first
        existing_user = User.where(email: row["UPDATE EMAIL"]&.strip).first

        #skip_service = nil
        if existing_organisation.present?
          if existing_user.present? && (existing_user.organisation_id == existing_organisation.id)
            # All good - user and org already exist
          elsif existing_user.present? && (existing_user.organisation_id != existing_organisation.id)
            puts "Whilst adding service #{row["Name"]}, an existing user #{existing_user.email} already exists in another Organisation: #{existing_user.organisation.id}, therefore cannot add to org: #{existing_organisation.id}"
            #skip_service = true
          else
            create_user(row["UPDATE EMAIL"]&.strip, existing_organisation) if row["UPDATE EMAIL"].present?
          end
          organisation = existing_organisation
        else
          new_organisation = Organisation.new(name: row["BFIS Parent"]&.strip)
          new_organisation.skip_mongo_callbacks = true
          
          unless new_organisation.save
            puts "Organisation #{new_organisation.name} failed to save, error message: #{new_organisation.errors.messages}"
          end
          
          if existing_user.present? && existing_user.organisation.present?
            puts "Whilst adding service #{row["Name"]}, foud that User #{existing_user.email} already exists in organisation #{existing_user.organisation.id} so cannot add it to new org: #{new_organisation.id}"
          elsif existing_user.present? && !existing_user.organisation.present?
            puts "Adding user to new organisation"
            existing_user.organisation = new_organisation
            existing_user.save
          else
            create_user(row["UPDATE EMAIL"]&.strip, new_organisation) if row["UPDATE EMAIL"].present?
          end

          organisation = new_organisation
        end

        service = Service.new(
          organisation_id: organisation.id,
          name: row["Name"]&.strip,
          description: row["Description"]&.strip,
          url: row["URL"]&.strip,
          visible: set_visibility(row["Review status"]&.strip),
          min_age: set_min_age(row["Age groups"]),
          max_age: set_max_age(row["Age groups"]),
          old_open_objects_external_id: row["Asset ID"]
        )
        service.skip_mongo_callbacks = true

        service.directories << Directory.where(name: "Buckinghamshire Online Directory").first

        if service.save
          # CUSTOM FIELDS
          if row["Volunteer DBS check"].present?
            service_meta = service.meta.new(key: "Volunteer DBS check", value: row["Volunteer DBS check"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Safeguarding"].present?
            service_meta = service.meta.new(key: "Safeguarding", value: row["Safeguarding"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Health and safety?"].present?
            service_meta = service.meta.new(key: "Health and safety?", value: row["Health and safety?"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Insurance?"].present?
            service_meta = service.meta.new(key: "Insurance?", value: row["Insurance?"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["confid data protect"].present?
            service_meta = service.meta.new(key: "Confid data protect", value: row["confid data protect"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["equality diversity"].present?
            service_meta = service.meta.new(key: "Equality diversity", value: row["equality diversity"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["PCN"].present?
            service_meta = service.meta.new(key: "Primary Care Network", value: row["PCN"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Community Board"].present?
            service_meta = service.meta.new(key: "Community board for Buckinghamshire Council", value: row["Community Board"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["GDPR Permission "].present?
            service_meta = service.meta.new(key: "GDPR Permission", value: row["GDPR Permission "]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["GDPR Authorised By"].present?
            service_meta = service.meta.new(key: "GDPR Authorised By", value: row["GDPR Authorised By"]&.strip)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["GDPR Permission Date"].present?
            service_meta = service.meta.new(key: "GDPR Permission Date", value: row["GDPR Permission Date"]&.strip.to_date)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
          if row["Review date"].present?
            service_meta = service.meta.new(key: "Review date", value: row["Review date"]&.strip.to_date)
            unless service_meta.save
              puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
            end
          end
        else
          puts "Service #{service.name} failed to save, error message: #{service.errors.messages}"
        end

        if (row["Contact name"]&.strip.present? || row["Email"]&.strip.present? || row["Phone"]&.strip.present?)
          contact = Contact.new(
            name: row["Contact name"]&.strip,
            email: row["Email"]&.strip,
            phone: row["Phone"]&.strip
          )
          service.contacts << contact
          unless contact.save
            puts "Contact #{contact.name} failed to save for service #{service.name}, error message: #{contact.errors.messages}"
          end
        end

        long_lat = row["Long-Lat"]&.split(",")
        location = Location.new(
          #name: row["genericField5"],
          postal_code: row["Postcode"]&.strip,
          city: row["Area"]&.strip,
          latitude: long_lat.kind_of?(Array) ? long_lat[1] : nil,
          longitude: long_lat.kind_of?(Array) ? long_lat[0] : nil,
          address_1: row["Venue"]&.strip,
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
  
    task :import_costs => [ :environment ] do

      csv_file = File.open('lib/seeds/bod/costs.csv', "r:utf-8")
      costs_csv = CSV.parse(csv_file, headers: true)

      costs_csv.each.with_index do |row, line|
        service = Service.where(old_open_objects_external_id: row["asset ID"]).first
        if service.present?
          if row["Free?"] == "Yes"
            service.skip_mongo_callbacks = true
            service.free = true
            unless service.save
              puts "Service #{service.id} failed to save as free"
            end
          end
        end
      end
    end

    task :apply_bfis_directory_to_current => :environment do
      set_existing_services_as_bfis
    end

    task :mark_duplicates_as_bod => :environment do
      csv_file = File.open('lib/seeds/bod/duplicates.csv', "r:utf-8")
      duplicates_csv = CSV.parse(csv_file, headers: true)

      duplicates_csv.each.with_index do |row, line|
        if row["Dir"] == "BOD"
          service = Service.find(row["BFIS ID"])
          service.skip_mongo_callbacks = true
          service.directories << Directory.where(name: "Buckinghamshire Online Directory").first
          unless service.save
            puts "Service #{service.id} failed to save whilst applying BOD directory"
          end
        end
      end
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
        s.directories_as_text = s.directories&.map{ |dir| dir.name }&.uniq&.sort&.join(", ") # make sure directories always in same order and no duplicates in there
        s.save
      end
    end

    task :save_all_and_clear_duplicate_directories => [ :environment ] do
      Service.all.each_with_index do |s, index|
        puts "Saving service #{s.name} (#{index})"
        s.directories = s.directories.uniq
        s.save
      end
    end
  end
end

def set_existing_services_as_bfis
  puts "Applying BFIS directory existing services"
  Service.all.each do |service|
    service.skip_mongo_callbacks = true
    service.directories << Directory.where(name: "Family Information Service").first
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