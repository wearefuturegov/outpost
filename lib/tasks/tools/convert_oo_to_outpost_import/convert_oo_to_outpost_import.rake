namespace :convert do
  desc 'convert open objects csv export to outpost import'
  task :openobjects, [:file_path] => :environment do |_t, args|
    args.with_defaults(file_path: Rails.root.join('lib', 'seeds', 'openobjects.csv'),
                       output_file_path: Rails.root.join('lib', 'seeds', 'services.csv'))

    file = File.open(args.file_path, 'r:ISO-8859-1')
    csv_parser = CSV.parse(file, headers: true, skip_blanks: true, skip_lines: /^(?:,\s*)+$/)

    # @TODO - support for custom custom_fields

    HEADERS = %w[
      import_id import_id_reference name description organisation url approved visible_from visible_to visible needs_referral min_age max_age notes service_taxonomies contact_name contact_title contact_visible contact_email contact_phone location_name location_latitude location_longitude location_address_1 location_city location_postcode location_visible mask_exact_address preferred_for_post location_accessibilities free cost_option cost_amount cost_type temporarily_closed schedules_opens_at schedules_closes_at scheduled_weekday links_label links_url labels suitabilities is_local_offer send_needs_support support_description recent_send_report outcomes recent_send_training parental_involvement information_sharing environment_accessibility how_to_start future_plans custom_select_user_type
    ]

    # doing these before we do anything since they're the most likely things to have to fix

    # no duplicate names
    name_duplicate = check_for_duplicates(csv_parser, 'title')

    # no duplicate externalid's
    externalid_duplicate = check_for_duplicates(csv_parser, 'externalid')

    initial_validation_has_errors = [name_duplicate,externalid_duplicate].any?
    # initial_validation_has_errors = false

    # open objects
    # title,service_type,sharingportal_inbound,sharingportal_inbound_owner,sharingportal_inbound_notes,sharingportal_inbound_link,sharingportal_inbound_image,description,contact_name,contact_position,contact_telephone,contact_email,website,contact_notes,venue_name,venue_address_1,venue_address_2,venue_address_3,venue_address_4,venue_address_5,venue_postcode,location_postcode,location_ward,location_coverage,venue_notes,date_displaydate,date_activity_period,date_timeofday,date_session_info,date_add_to_whatson,date_featured_whatson,cost_table,cost_description,referral_required,referral_notes,agerange,notes_public,logo,images,files,related_links,parent_organisation,parent_organisation_contact_show,parent_organisation_venue_show,ecd_type_list,ecd_daycaretype_list,dfes_urn,vendor_urn,registered_setting_identifier,ecd_places_max,places_range,ecd_funded_registered,ecd_funded_registered_2yo,ecd_funded_places_2yo,ecd_funded_places_3yo,ecd_funded_places_4yo,ecd_funded_places_total,ecd_30_hours,ecd_vacancies_over8,ecd_age_from_years,ecd_age_from_months,ecd_age_to_years,ecd_age_to_months,ecd_vacancies_immediate,ecd_vacancies_max,ecd_vacancy_range,ecd_vacancies_details,ecd_vacancies_modified,ecd_vacancies_contactprovider,ecd_facilities_list,ecd_timetable_openinghours_list,ecd_timetable_list,ecd_timetable_otherhours,ecd_pickup,ecd_pickup_details,ecd_pickup_schools_list,ecd_sp_wheelchairaccess,ecd_sp_wheelchairaccess_details,ecd_sp_specialdiet,ecd_sp_specialdiet_details,ecd_sp_specialdiet_experience_list,ecd_sp_specialneeds,ecd_sp_specialneeds_details,ecd_sp_specialneeds_experience_list,ecd_sp_cultural,ecd_sp_cultural_details,ecd_sp_cultural_experience_list,ecd_other_notes,lo_response_type_required,services,supporting,attributes,familychannel,adultchannel,youthchannel,localofferchannel,cqc_id,cqc_rating,cqc_reportdate,keywords,lo_boolean,lo_show_flash,lo_details,lo_contact_name,lo_contact_telephone,lo_contact_email,lo_links,lo_age_bands,lo_needs_level,lo_sen_provision_type,lo_provider_form_approved,lo_file,lo_school_01,lo_school_02,lo_school_03,lo_school_04,lo_school_05,lo_school_06,lo_school_07,lo_school_08,lo_school_09,lo_school_10,lo_school_11,lo_school_12,lo_school_13,group_assignment,record_editor,record_activity_range,record_id,__url,admin_history,notes_private,ecd_opt_out_website,public_address_1,public_address_2,public_address_3,public_address_4,public_address_5,public_address_postcode,public_address_map_postcode,private_name,private_position,private_telephone,private_email,private_address_1,private_address_2,private_address_3,private_address_4,private_address_5,private_postcode,dormant,review_allowed,review_average,sharingportal_outbound,entrysource,externalid,lastupdated

    # outpost import
    # import_id,import_id_reference,name,description,organisation,url,approved,visible_from,visible_to,visible,needs_referral,min_age,max_age,notes,service_taxonomies,contact_name,contact_title,contact_visible,contact_email,contact_phone,location_name,location_latitude,location_longitude,location_address_1,location_city,location_postcode,location_visible,mask_exact_address,preferred_for_post,location_accessibilities,free,cost_option,cost_amount,cost_type,temporarily_closed,schedules_opens_at,schedules_closes_at,scheduled_weekday,links_label,links_url,labels,suitabilities,is_local_offer,send_needs_support,support_description,recent_send_report,outcomes,recent_send_training,parental_involvement,information_sharing,environment_accessibility,how_to_start,future_plans,custom_text_text_field,custom_checkbox_checkbox_field,custom_number_number_field,custom_select_select_field,custom_date_date_fields

    if initial_validation_has_errors
      puts '😭 Import will fail, data is not valid, see errors above.'
    else
      puts '🟢 Validation passed, continuing with import 🥁'
      csv_data = convert_csv(csv_parser)
      create_csv(csv_data, args.output_file_path)
    end
  end

  # convert the csv
  def convert_csv(csv_data)
    @service_csv_data = []

    csv_data.each.with_index do |row, index|
      @parent_service_import_id = (index+1) + @service_csv_data.length
      @parent_service = {}
      @parent_service_name = row['title']&.strip

      if @parent_service_name.length > 100 
        abort("  🔴 Name: Service name is limited to 100 characters \"#{@parent_service_name}\"")
      end

      # @TODO website might have multiple urls on different lines but none of the test data so far has had any urls!
      # essentials
      @basic = {
        import_id: @parent_service_import_id,
        import_id_reference: nil,
        name: @parent_service_name,
        description: row["description"].html_safe,
        # url: row["website"],
        needs_referral: row['referral_required'] === 'Yes',
        approved: true,
        labels: 'adults-import-1'
      }
      @parent_service = @parent_service.merge(**@basic)

      # organisations
      # parent_organisation
      # parent_organisation_contact_show
      # parent_organisation_venue_show
      # @TODO add validation step - if parent_organisation is set but cant find the matching one - throw and error
      unless row['parent_organisation'].nil?
        organisation_rows = csv_data.select.with_index { |item, _i| item['externalid'] === row['parent_organisation'] }
        if organisation_rows.length == 0
          puts "🟠 Organisation: Missing matching service externalId for \"#{@parent_service_name}\", ignoring and leaving blank for now"
        elsif organisation_rows.length == 1
          @organisations = organisation_rows.first["title"]&.strip
          @organisations = {
            organisation: !@organisations.nil? ? organisation_rows.first["title"]&.strip : nil
          }
          @parent_service = @parent_service.merge(**@organisations)
        end
      end

      # taxonomies
      #   service_taxonomies: "",

      @taxonomies_values = []
      @taxonomies_values.concat(row['familychannel'].split(/\n/).collect(&:strip).uniq) unless row['familychannel'].nil?
      @taxonomies_values.concat(row['adultchannel'].split(/\n/).collect(&:strip).uniq) unless row['adultchannel'].nil?
      @taxonomies_values.concat(row['youthchannel'].split(/\n/).collect(&:strip).uniq) unless row['youthchannel'].nil?
      unless row['localofferchannel'].nil?
        @taxonomies_values.concat(row['localofferchannel'].split(/\n/).collect(&:strip).uniq)
      end

      unless @taxonomies_values.nil?

        @taxonomies_values = {
          service_taxonomies: @taxonomies_values.join("\;")
        }
        @parent_service = @parent_service.merge(**@taxonomies_values)
      end

      # contacts

      @contacts = []

      # @TODO record_editors as users to import?

      # "Please provide contact details for members of the public to use"
      if !row['contact_name'].blank? && !row['contact_email'].blank? && !row['contact_telephone'].blank?
        @contacts << {
          contact_name: row['contact_name']&.strip,
          contact_title: row['contact_position']&.strip,
          contact_phone: row['contact_telephone']&.strip,
          contact_email: row['contact_email']&.strip,
          contact_visible: true
        }
      end

      # "It this record has been submitted via a website Add Entry form then one or all of these fields will be completed. This is useful if you need to contact the person who submitted the record."
      if !row['submitter_name'].blank? && !row['submitter_email'].blank? && !row['submitter_telephone'].blank?
        @contacts << {
          contact_name: row['submitter_name']&.strip,
          contact_title: row['submitter_telephone']&.strip,
          contact_phone: row['submitter_email']&.strip,
          contact_email: row['submitter_comments']&.strip,
          contact_visible: false
        }
      end

      # "this section is for the private contact details of the service provider. these fields will not be shown on the website"
      if !row['private_name'].blank? && !row['private_email'].blank? && !row['private_telephone'].blank?
        @contacts << {
          contact_name: row['private_name']&.strip,
          contact_title: row['private_position']&.strip,
          contact_phone: row['private_telephone']&.strip,
          contact_email: row['private_email']&.strip,
          contact_visible: false
        }
      end

      # @contacts = array.uniq! {|c| [c.first, c.second]}
      @contacts = @contacts.uniq {|hash| hash.values_at(:contact_name, :contact_email, :contact_phone)}
      # puts @contacts.uniq! {|e| e[:contact_name] }

      @parent_service = @parent_service.merge(**@contacts[0]) if !@contacts.nil? && @contacts.length >= 1
      @contacts = @contacts.drop(1)

      # location

      #   location_name: "",
      #   location_latitude: "",
      #   location_longitude: "",
      #   location_address_1: "",
      #   location_city: "",
      #   location_postcode: "",
      #   location_visible: "",
      #   mask_exact_address: "",
      #   preferred_for_post: "",
      #   location_accessibilities: "",

      @name = [row['public_address_1']&.strip, row['public_address_2']&.strip].reject(&:nil?).uniq.join(', ')
      @address_1 = [row['public_address_1']&.strip, row['public_address_2']&.strip,
                    row['public_address_3']&.strip].reject(&:nil?).uniq.join(', ')
      @city = [row['public_address_4']&.strip, row['public_address_5']&.strip].reject(&:nil?).uniq.join(', ')
      @postcode = row['public_address_postcode']&.strip
      unless @postcode.nil?
        if [row['public_address_1']&.strip, row['public_address_2']&.strip, row['public_address_3']&.strip, row['public_address_4']&.strip, row['public_address_5']&.strip].flatten.length > 0
          puts "🟠 Location: Missing postcode for \"#{@parent_service_name}\", it will be imported without a location"
        end
      end

      @location_address = {
        location_name: !@name.nil? ? @name : nil,
        location_address_1: !@address_1.nil? ? @address_1 : nil,
        location_city: !@city.nil? ? @city : nil,
        location_postcode: @postcode
      }
      # Full visibility on public website
      # Hide street level location but show on maps
      # Hide street level location and don't show on maps
      # Hide full location and don't show on maps
      # Hide completely from public website
      # Admin access only, never on website
      @ecd_opt_out_website = row['ecd_opt_out_website']

      case @ecd_opt_out_website
        when "Full visibility on public website"
          @location_visibility = {
            location_visible: true,
            mask_exact_address: false
          }
        when "Hide street level location but show on maps"
          @location_visibility = {
            location_visible: true,
            mask_exact_address: true
          }
        when "Hide street level location and don't show on maps"
          @location_visibility = {
            location_visible: false,
            mask_exact_address: true
          }
        when "Hide full location and don't show on maps"
          @location_visibility = {
            location_visible: false,
            mask_exact_address: true
          }
        when "Hide completely from public website"
          @location_visibility = {
            location_visible: false,
            mask_exact_address: true
          }
        when "Admin access only, never on website"
          @location_visibility = {
            location_visible: false,
            mask_exact_address: true
          }
        else 
          # default to hidden location
          @location_visibility = {
            location_visible: false,
            mask_exact_address: true
          }
      end

      if !@postcode.nil? && @postcode.length > 6
        @parent_service = @parent_service.merge(**@location_address, **@location_visibility)
      end

      # costs
      # --- free
      unless row['attributes'].nil?
        @attributes = row['attributes'].split(/\n/).collect(&:strip).uniq
        if @attributes.include? 'Service/Activity is Free'
          @costs = {
            free: true
          }
          @parent_service = @parent_service.merge(**@costs)
        end
      end

      # @TODO missing this info + functionality costs, cost_table, cost_description
      #   cost_option: "",
      #   cost_amount: "",
      #   cost_type: "",

      # suitabilities
      unless row['supporting'].nil?
        @suitabilities = {
          suitabilities: row['supporting'].split(/\n/).collect(&:strip).uniq.join(';')
        }
        @parent_service = @parent_service.merge(**@suitabilities)
      end

      # visibility
      @visibility = {
        visible: true
      }
      unless row['record_activity_range'].nil?
        dates = row['record_activity_range'].split('-').collect(&:strip)
        @visibility = if dates.length == 2
                        {
                          visible_from: Date.strptime(dates[0], '%d/%m/%Y').to_s,
                          visible_to: Date.strptime(dates[1], '%d/%m/%Y').to_s
                        }
                      elsif dates.length == 1
                        {
                          visible_from: Date.strptime(dates[0], '%d/%m/%Y').to_s
                        }
                      end
      end
      @parent_service = @parent_service.merge(**@visibility)

      # ages
      # @TODO ages arent formatted correctly in csv
      unless row['agerange'].nil?
        # @ages = {
        #   min_age: "",
        #   max_age: "",
        # }
      end

      # schedule
      # @TODO we can import some dates as an 'event date' custom field?
      # @TODO always on date times don't come over
      # @TODO we could set morning afternoon evening flags ... if we had the data!
      #   temporarily_closed: "",
      #   schedules_opens_at: "",
      #   schedules_closes_at: "",
      #   scheduled_weekday: "",

      # links
      # @TODO are related_url and related_url_title links?
      # @TODO data is missing from current import task
      #   links_label: "",
      #   links_url: "",

      # notes
      unless row['notes_private'].nil?
        @notes = {
          notes: row['notes_private']
        }
        @parent_service = @parent_service.merge(**@notes)
      end

      # @TODO local offer
      #   is_local_offer: "",
      #   send_needs_support: "",
      #   support_description: "",
      #   recent_send_report: "",
      #   outcomes: "",
      #   recent_send_training: "",
      #   parental_involvement: "",
      #   information_sharing: "",
      #   environment_accessibility: "",
      #   how_to_start: "",
      #   future_plans: "",

      # custom fields

      unless row['services'].nil?
        @custom_fields = {
          custom_select_user_types: !row['services'].nil? ? row['services'].split(/\n/).collect(&:strip).uniq.join(';') : nil
        }
        @parent_service = @parent_service.merge(**@custom_fields)
      end

      #   custom_text_text_field: "",
      #   custom_checkbox_checkbox_field: "",
      #   custom_number_number_field: "",
      #   custom_select_select_field: "",
      #   custom_date_date_fields: "",

      @service_csv_data << @parent_service

      @child_service_import_id_reference = @parent_service_import_id
      if !@contacts.nil?
        @contacts.each do |c, i|
          # next unless i != 0
          @parent_service_import_id += 1
          @service_csv_data << { import_id: @parent_service_import_id,
                                import_id_reference: @child_service_import_id_reference, **c }
        end
      end
      
      @parent_service_import_id += 1
    end

    @service_csv_data.reject(&:empty?)

  end

  def create_csv(csv_data, output_file_path)
    CSV.open(output_file_path, 'wb', headers: HEADERS, write_headers: true) do |csv|
      csv_data.each do |row|
        csv << HEADERS.map { |header| row[header.to_sym] }
      end
    end
  end

  # @TODO share this between scripts
  # check for duplicates in a given column
  def check_for_duplicates(csv_data, column_name)
    data = csv_data.select { |item| !item[column_name].nil? }
    value = data.map { |i| i[column_name] }
    duplicates = value.filter { |e| value.count(e) > 1 }.sort.uniq
    naughty_values = duplicates.map { |i, _a| " 👉 \"#{i}\"" }.join("\n")
    return false unless value.uniq.length != value.length

    puts "🔴 Found some services with the same #{column_name} \n\n#{naughty_values}\n\n"
    true
  end
end
