require 'csv'

namespace :services do

  # Undoes evertything in create_from_csv taks so that it can be run again without running entire seed
  task :clear_with_related_data => [ :environment ] do
    ServiceMeta.destroy_all
    Service.destroy_all
    Location.destroy_all
    Contact.destroy_all
    SendNeed.destroy_all
  end

  task :create_from_csv => [ :environment ] do
    users_file = File.open('lib/seeds/users.csv', "r:utf-8")
    open_objects_users_csv = CSV.parse(users_file, headers: true)

    csv_file = File.open('lib/seeds/bucksfis geo.csv', "r:utf-8")
    bucks_csv = CSV.parse(csv_file, headers: true)

    bucks_csv.each.with_index do |row, line|
      #next unless (line % 6 == 0)
      puts "Processing line (service build): #{line} of #{bucks_csv.size}"

      open_objects_users = open_objects_users_csv.select{ |user_row| user_row['externalId'] == row['record_editor'] } # users from open objects csv
      outpost_users = User.where(old_external_id: row['record_editor']) # new database users already created by this seed

      # FIND OR CREATE ORG

      organisation = Organisation.where(old_external_id: row['parent_organisation']).first unless row['parent_organisation'].nil? # find from parent ID
      organisation ||= outpost_users.first&.organisation # find from user
      organisation ||= Organisation.where(old_external_id: row['externalid']).first # if for service that is also org

      if organisation.blank?
        organisation = Organisation.new
        organisation.skip_mongo_callbacks = true
        unless organisation.save
          puts "Organisation #{organisation.name} failed to save: #{organisation.errors.messages}"
        end
      end

      # CREATE USER IF DOESN'T ALREADY EXIST AND DID PREVIOUSLY
      if outpost_users.blank? & open_objects_users.any?
        open_objects_user = open_objects_users.first
        password = "A9b#{SecureRandom.hex(8)}1yZ"
        user = User.new
        user.email = open_objects_user['email']
        user.old_external_id = open_objects_user['externalId']
        user.first_name = open_objects_user['firstName']
        user.last_name = open_objects_user['lastName']
        user.organisation_id = organisation.id
        user.password = password
        unless user.save
          puts "User #{user.email} failed to save: #{user.errors.messages}"
        end
      end

      # CREATE SERVICE

      service ||= Service.new

      if (row['ecd_opt_out_website'] == "Hide completely from public website") || (row['ecd_opt_out_website'] == "Admin access only, never on website")
        service.visible = false
      end

      if row['service_type'] == 'Childcare'
        if row['registered_setting_identifier'].present?
          ofsted_item = OfstedItem.where(open_objects_external_id: row['registered_setting_identifier']).first
          service.ofsted_item_id = ofsted_item.id if ofsted_item
        end
      end

      service.name = row['title']
      service.description = ActionView::Base.full_sanitizer.sanitize(row['description'])
      service.url = row['website']
      service.needs_referral = true if row['referral_required'] == 'Yes'
      service.old_open_objects_external_id = row['externalid']

      service.links.build(label: 'Facebook', url: row['facebook']) if row['facebook'].present?
      service.links.build(label: 'Twitter', url: row['twitter']) if row['twitter'].present?
      service.links.build(label: 'Soundcloud', url: row['soundcloud']) if row['soundcloud'].present?
      service.links.build(label: 'LinkedIn', url: row['linkedin']) if row['linkedin'].present?
      service.links.build(label: 'Instagram', url: row['instagram']) if row['instagram'].present?
      service.links.build(label: 'Pinterest', url: row['pinterest']) if row['pinterest'].present?
      service.links.build(label: 'YouTube', url: row['youtubechannel']) if row['youtubechannel'].present?
      service.links.build(label: 'Vimeo', url: row['vimeochannel']) if row['vimeochannel'].present?

      service.organisation = organisation

      service.paper_trail_event = "import"

      unless ['Nationwide', 'Online', 'Buckinghamshire'].include?(row['venue_address_4']) # Do not create location of online/nationwide service
        location = Location.new
        if row['ecd_opt_out_website'] == "Hide street level location and don't show on maps"
          location.visible = false
        elsif row['ecd_opt_out_website'] == "Hide street level location but show on maps"
          location.mask_exact_address = true
        end

        location.name = row['venue_name']
        location.address_1 = [row['venue_address_1'], row['venue_address_2']].join(' ')
        location.city = row['venue_address_4']
        location.state_province = 'Buckinghamshire'
        location.postal_code = row['venue_postcode']
        location.latitude = row['latitude']
        location.longitude = row['longitude']
        location.country = 'GB'

        # add accessibility info to locations
        unless row['venue_facilities'] == nil
          options = row['venue_facilities'].split("\n")
          # remove unwanted values
          options = options - ["Accessible Website", "Cooking"]
          options.each do |option|
            location.accessibilities << Accessibility.find_or_initialize_by({name: option.downcase.capitalize})
          end
        end

        location.skip_postcode_validation = true
        location.skip_mongo_callbacks = true
        unless location.save
          puts "Location #{location.name} failed to save: #{location.errors.messages}"
        end
        service.locations << location
      end

      unless row['attributes'] == nil
        attributes = row['attributes'].split("\n")
        attributes.each do |attribute|

          if attribute === "Free/Low Cost"
            service.free = true
          end

          # cost_taxonomy_path = ["Cost", attribute]
          # taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(cost_taxonomy_path)
          # service.taxonomies |= [taxonomy]
        end
      end

      # unless row['coronavirus_status'] == nil
      #   coronavirus_statuses = row['coronavirus_status'].split("\n")
      #   coronavirus_statuses.each do |coronavirus_status|
      #     coronavirus_status_path = ["Coronavirus status", coronavirus_status]
      #     taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(coronavirus_status_path)
      #     service.taxonomies |= [taxonomy]
      #   end
      # end

      # handle local offer
      if row['lo_boolean'] == "Yes"
        local_offer = LocalOffer.new
        local_offer.description = ActionView::Base.full_sanitizer.sanitize(row['lo_details'])
        local_offer.skip_description_validation = true

        survey_answers = []

        mapping = [
          {id: 1, answer: (row['general_01'] || "") + "\r\n\r\n" + (row['general_02'] || "") + "\r\n\r\n" + (row['early_years_4'] || "")},
          {id: 2, answer: (row['general_06'] || "") + "\r\n\r\n" + (row['early_years_1'] || "")},
          {id: 3, answer: row['early_years_2']},
          {id: 4, answer: (row['general_05'] || "") + "\r\n\r\n" + (row['early_years_3'] || "")},
          {id: 5, answer: (row['general_04'] || "") + "\r\n\r\n" + (row['early_years_5'] || "")},
          {id: 6, answer: (row['general_03'] || "") + "\r\n\r\n" + (row['early_years_6'] || "") + "\r\n\r\n" + (row['lo_school_04'] || "")},
          {id: 7, answer: (row['general_07'] || "") + "\r\n\r\n" + (row['early_years_7'] || "") + "\r\n\r\n" + (row['lo_school_05'] || "")}
        ]

        mapping.each do |m|
          survey_answers[m[:id] -1] = {id: m[:id], answer: ActionView::Base.full_sanitizer.sanitize(m[:answer])&.strip}
        end

        local_offer.survey_answers = survey_answers
        service.local_offer = local_offer
      end

      unless row['lo_age_bands'] == nil
        age_groups = row['lo_age_bands'].split("\n")

        min_age = age_groups.map {|x| x.scan(/\d+/)}.flatten.map(&:to_i).min
        max_age = age_groups.map {|x| x.scan(/\d+/)}.flatten.map(&:to_i).max

        max_age = nil if age_groups.include? "25 plus"

        if age_groups.include? "All ages"
          min_age = nil
          max_age = nil
        end

        service.min_age = min_age
        service.max_age = max_age
      end

      unless row['lo_needs_level'] == nil
        send_needs = row['lo_needs_level'].split("\n")

        send_needs.each do |send_need|
          service.send_needs << SendNeed.find_or_initialize_by({name: send_need.downcase.capitalize})
        end

        if send_needs.include? "All Needs Met"
          service.send_needs << SendNeed.all
        end

      end

      unless row['familychannel'] == nil
        lines = row['familychannel'].split("\n")
        lines.each do |line|
          categories = line.split(' > ')
          categories.delete("Family Information")

          taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
          service.taxonomies |= [taxonomy]
        end
      end

      unless row['parentchannel'] == nil
        lines = row['parentchannel'].split("\n")
        lines.each do |line|
          categories = line.split(' > ')
          taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
          service.taxonomies |= [taxonomy]
        end
      end

      unless row['youthchannel'] == nil
        lines = row['youthchannel'].split("\n")
        lines.each do |line|
          categories = line.split(' > ')
          taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
          service.taxonomies |= [taxonomy]
        end
      end

      unless row['childrenscentrechannel'] == nil
        lines = row['childrenscentrechannel'].split("\n")
        lines.each do |line|
          categories = line.split(' > ')
          taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
          service.taxonomies |= [taxonomy]
        end
      end

      service.skip_mongo_callbacks = true

      service.locations.each {|l| l.skip_postcode_validation = true }
      if service.save
        # CUSTOM FIELDS
        if row["dfes_urn"].present?
          service_meta = service.meta.new(key: "Funding URN", value: row["dfes_urn"])
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end

        if row["ecd_funded_places_2yo"].present?
          service_meta = service.meta.new(key: "Funding 2 year olds", value: row["ecd_funded_places_2yo"])
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end

        if (row["ecd_funded_places_3yo"].present? || row["ecd_funded_places_4yo"]).present?
          service_meta = service.meta.new(key: "Funding 3/4 year olds", value: (row["ecd_funded_places_3yo"].to_i + row["ecd_funded_places_4yo"].to_i))
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end

        if row["owner"].present?
          service_meta = service.meta.new(key: "Type of ownership", value: row["owner"].capitalize.sub("Nhs", "NHS"))
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end

        if row["ecd_pickup"].present?
          service_meta = service.meta.new(key: "Do you provide a pick-up/drop-off service?", value: row["ecd_pickup"])
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end

        if row["ecd_places_max"].present?
          service_meta = service.meta.new(key: "Maximum number of children", value: row["ecd_places_max"])
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end
        if row["ecd_funded_places_total"].present?
          service_meta = service.meta.new(key: "Total funded places", value: row["ecd_funded_places_total"])
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end
        if row["ecd_daycaretype_list"].present?
          service_meta = service.meta.new(key: "Daycare type", value: row["ecd_daycaretype_list"].capitalize.sub("Sen", "SEN"))
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end
        if row["ecd_type_list"].present?
          service_meta = service.meta.new(key: "Provider type", value: row["ecd_type_list"].capitalize)
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end
        if row["sector"].present?
          service_meta = service.meta.new(key: "Sector", value: row["sector"].capitalize)
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end
        if row["ecd_timetable_weeksopen"].present?
          service_meta = service.meta.new(key: "How many weeks in a calendar year are you open?", value: row["ecd_timetable_weeksopen"])
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end
        if row["ecd_sp_childcare_orgs"].present?
          service_meta = service.meta.new(key: "BCCN", value: row["ecd_sp_childcare_orgs"])
          unless service_meta.save
            puts "Service meta #{service_meta.key} failed to save: #{service_meta.errors.messages}"
          end
        end
      else
        puts "Service #{service.name} failed to save: #{service.errors.messages}"
      end

      if (row['contact_name'].present? || row['contact_telephone'].present? || row['contact_email'].present?) # contact just needs one of these ethings to save
        contact = Contact.new
        contact.service_id = service.id
        contact.name = row['contact_name']
        contact.title = row['contact_position']
        contact.email = row['contact_email']

        # If more than one number, add first to contact with name, email and position, and create blank contacts for remaining numbers
        if row['contact_telephone'].present?
          if row['contact_telephone']&.include? "\n"
            numbers = row['contact_telephone'].split("\n")
            contact.phone = numbers.first

            unless contact.save
              puts "Contact #{contact.name} failed to save: #{contact.errors.messages}"
            end

            numbers = numbers.drop(1) # now create contacts for remaining numbers
            numbers.each do |number|
              contact = Contact.new
              contact.phone = number
              contact.service_id = service.id
              unless contact.save
                puts "Phone #{number} failed to save: #{contact.errors.messages}"
              end
            end
          end
        end
      end

    end
  end
end
