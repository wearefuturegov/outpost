namespace :import do
  desc 'import services from csv file to database'
  task :services, [:file_path] => :environment do |t, args|
    args.with_defaults(file_path: Rails.root.join('lib', 'seeds', 'services.csv'))

    file = File.open(args.file_path, "r:ISO-8859-1")
    csv_parser = CSV.parse(file, headers: true, skip_blanks: true, skip_lines: /^(?:,\s*)+$/)

    # TODO
    # locations import twice
    # links import twice
    # opening times import twice
    # opening times not all importing

    # doing these before we do anything since they're the most likely things to have to fix

    # all rows should have import_id set
    import_id_required = check_required_field_exists(csv_parser, 'import_id')

    # no duplicate import_ids
    import_id_duplicates = check_for_duplicates(csv_parser, 'import_id')

    # check import_id is numeric only
    import_id_numeric = check_is_numeric(csv_parser, 'import_id')

    # check import_id_reference is numeric only
    import_id_reference_numeric = check_is_numeric(csv_parser, 'import_id_reference')

    # no duplicate names 
    name_duplicate = check_for_duplicates(csv_parser, 'name')

    # if import_id is there so must name be
    name_import_id_exist = check_name_import_id(csv_parser)

    # TODO boolean fields
    # free is boolean
    # free_is_boolean = check_is_boolean(csv_parser, 'free')


    initial_validation_has_errors = [import_id_required,import_id_duplicates,import_id_numeric,import_id_reference_numeric,name_duplicate,name_import_id_exist].any?  

    if initial_validation_has_errors 
      puts "😭 Import will fail, data is not valid, see errors above."
    else 
      puts "🟢 Validation passed, continuing with import 🥁"
      import_services(csv_parser)
    end

  end


  # Do the import
  def import_services(csv_data)
    csv_data.each.with_index do |row, index|
      service_id = import_parent_service(row)
      if service_id
        child_rows = csv_data.select{|item| item['import_id_reference'] === row['import_id']}
        # @TODO this causes duplicates in the db
        child_rows.each do |child_row|
          append_data_to_all_row_types(service_id, child_row)
        end
      end
    end
  end


  # import the service meta
  def import_service_meta(type, service_id, rows, fields, row)

    if CustomField.types.map!(&:downcase).include? type
      rows.map do |t|

        custom_field = fields.filter{|f| f["field"] === t}.first
        if custom_field.present?
          key = custom_field['key']
          value = row["custom_#{type}_#{t}"]

          case type
          when "text"
            value = value.nil? ? '' : value&.strip
          when "checkbox"
            value = !value.nil? ? value&.strip : ''
          when "number"
            value = CSV::Converters[:integer].call(value).is_a?(Numeric) ? CSV::Converters[:integer].call(value) : ''
          when "select"
            value = !value.nil? ? value.split(';').collect(&:strip).reject(&:empty?).uniq.join(',') : ''
          when "date"
            value = value&.strip&.to_date.present? ? value&.strip&.to_date : ''
          end

          if value.present?

            state = "created"
            new_service_meta_exists = ServiceMeta.where(service_id: service_id)
            if new_service_meta_exists
              state = "updated"
            end

            new_service_meta = ServiceMeta.find_or_create_by(service_id: service_id, key: key) do |new_sm|
              new_sm.key = key
              new_sm.value = value
            end

            if new_service_meta
              puts "  🟢 Service meta: #{state} (id #{new_service_meta.id})"
            else 
              abort("  🔴 Service meta: was not created. Exiting. #{new_service_meta.errors.messages}")
            end

          end
        end
      end
    end
  end

  def import_parent_service(row)
    if row['import_id_reference'] == nil 
      service = Service.find_by(name: row["name"]&.strip)
      if service
        puts "🟠 Service: \"#{row["name"]}\" already exists, skipping anything to do with this service (id: #{service.id})."
      else

        # @TODO to/from date validation
        # @TODO ensure booleans are booleans
        new_service = Service.new(
          name: row["name"]&.strip,
          description: row["description"]&.strip,
          url: row["url"]&.strip,
          approved: row["approved"],
          visible_from: row["visible_from"],
          visible_to: row["visible_to"],
          visible: (!row["visible_from"].nil? && !row["visible_to"].nil?) ? true : row["visible"],
          needs_referral: row["needs_referral"],
          free: row["free"],
          min_age: row["min_age"],
          max_age: row["max_age"],
          organisation: new_service_organisation(row['organisation']),
          temporarily_closed: row["temporarily_closed"],
          label_list: row['labels']&.split(';')&.collect(&:strip),
          skip_mongo_callbacks: true
        )
        if new_service.save
          service_id = new_service.id
          puts "🟢 Service: \"#{row["name"]}\" created (id: #{service_id})."
          puts " 👉 Now adding more to it"

          # deliminated data
          # Taxonomies
          new_service_taxonomies(new_service, row['service_taxonomies'])

          # Suitabilities
          new_service_suitabilities(new_service, row['suitabilities'])

          # SEND
          if row['is_local_offer'].present? && row['support_description'].present?
            new_service_local_offer(service_id, row)
          end 

          # SEND needs
          new_service_send_needs(new_service, row['send_needs_support'])


          # custom fields

          #yuck
          # @TODO loop through CustomField.types here
          text_rows = row.headers.filter{|h|h.starts_with?('custom_text_')}.map{|e| e.slice('custom_text_'.length, e.length) }
          text_field_info = []
          text_field = CustomField.where(field_type: 'text').map{|m| text_field_info << {"id" => m['id'], "key" => m['key'], "field" => m['key'].downcase.delete("^a-zA-Z0-9 ").gsub(' ', '_')}}
          import_service_meta('text', service_id, text_rows, text_field_info, row)

          checkbox_rows = row.headers.filter{|h|h.starts_with?('custom_checkbox_')}.map{|e| e.slice('custom_checkbox_'.length, e.length) }
          checkbox_field_info = []
          checkbox_fields = CustomField.where(field_type: 'checkbox').map{|m| checkbox_field_info << {"id" => m['id'], "key" => m['key'], "field" => m['key'].downcase.delete("^a-zA-Z0-9 ").gsub(' ', '_')}}
          import_service_meta('checkbox', service_id, checkbox_rows, checkbox_field_info, row)

          number_rows = row.headers.filter{|h|h.starts_with?('custom_number_')}.map{|e| e.slice('custom_number_'.length, e.length) }
          number_field_info = []
          number_fields = CustomField.where(field_type: 'number').map{|m| number_field_info << {"id" => m['id'], "key" => m['key'], "field" => m['key'].downcase.delete("^a-zA-Z0-9 ").gsub(' ', '_')}}
          import_service_meta('number', service_id, number_rows, number_field_info, row)

          select_rows = row.headers.filter{|h|h.starts_with?('custom_select_')}.map{|e| e.slice('custom_select_'.length, e.length) }
          select_field_info = []
          select_fields = CustomField.where(field_type: 'select').map{|m| select_field_info << {"id" => m['id'], "key" => m['key'], "field" => m['key'].downcase.delete("^a-zA-Z0-9 ").gsub(' ', '_')}}
          import_service_meta('select', service_id, select_rows, select_field_info, row)

          date_rows = row.headers.filter{|h|h.starts_with?('custom_date_')}.map{|e| e.slice('custom_date_'.length, e.length) }
          date_field_info = []
          date_fields = CustomField.where(field_type: 'date').map{|m| date_field_info << {"id" => m['id'], "key" => m['key'], "field" => m['key'].downcase.delete("^a-zA-Z0-9 ").gsub(' ', '_')}}
          import_service_meta('date', service_id, date_rows, date_field_info, row)


          ######### 
          # data that is valid on child and parent rows
          append_data_to_all_row_types(service_id, row)



        else 
          abort("🔴 Service: \"#{row["name"]}\" was not created. Exiting.  #{new_service.errors.messages}")
        end
      end
      return service_id
    end
  end





  # some fields can be applied on all row 'types' the parents and the child
  def append_data_to_all_row_types(service_id, row)
    service = Service.find(service_id)

    # contacts
    # TODO send only info contacts needs
    if row["contact_name"].present? || row["contact_email"].present? || row["contact_phone"].present?
      new_service_contact(service, row)
    end

    # notes
    if row["notes"].present?
      new_service_notes(service, row["notes"])
    end

    # location
    if row["location_postcode"].present?
      # @TODO this validation should go higher up
      new_service_location(service, row)
    end

    # costs
    if row["cost_option"].present? || row["cost_amount"].present? || row["cost_type"].present? 
      new_service_cost_option(service, row)
    end

    # schedule
    if row["schedules_opens_at"].present? && row["schedules_closes_at"].present? && row["scheduled_weekday"].present? 
      # @TODO this validation should go higher up
      new_service_regular_schedules(service_id, row)
    else 
      puts "  🟠 No schedule was created as not all fields contained data"
    end

    # links
    if row["links_label"].present?
      new_service_links(service, row)
    end
  end

  # create local offer
  def new_service_local_offer(service_id, send_needs_data)

    survey_answer_mappings = [
      { id: 1, key: send_needs_data["outcomes"] },
      { id: 2, key: send_needs_data["recent_send_training"] },
      { id: 3, key: send_needs_data["parental_involvement"] },
      { id: 4, key: send_needs_data["information_sharing"] },
      { id: 5, key: send_needs_data["environment_accessibility"] },
      { id: 6, key: send_needs_data["how_to_start"] },
      { id: 7, key: send_needs_data["future_plans"] },
    ]

    survey_answers = []
    survey_answer_mappings.each do |m|
      survey_answers[m[:id] -1] = {id: m[:id], answer: ActionView::Base.full_sanitizer.sanitize(m[:key])&.strip}
    end


    state = "created"
    local_offer_exists = LocalOffer.where(service_id: service_id)
    if local_offer_exists.exists?
      state = "updated"
    end

    new_local_offer = LocalOffer.find_or_create_by(service_id: service_id) do |new_lo|
      new_lo.description = send_needs_data["support_description"]
      new_lo.link = send_needs_data["recent_send_report"] if send_needs_data["recent_send_report"].present?
      new_lo.survey_answers = survey_answers
      new_lo.service_id = service_id
      new_lo.skip_description_validation = true
    end

    if new_local_offer
      puts "  🟢 Local offer: #{state}"
    else 
      abort("  🔴 Local offer: was not created. Exiting. #{new_local_offer.errors.messages}")
    end

  end

  # create SEND needs
  def new_service_send_needs(service, send_needs)
    send_needs&.split(';')&.collect(&:strip)&.each do |name|
      send_need = service.send_needs.find_or_initialize_by(name: name)
      if send_need.save
        puts "  🟢 Send need: \"#{name}\" created (id: #{send_need.id})."
      else
        abort("  🔴 Send need: \"#{name}\" was not created. Exiting. #{send_need.errors.messages}")
      end
    end
  end

  # create suitabilities
  def new_service_suitabilities(service, suitabilities)
    suitabilities&.split(';')&.collect(&:strip)&.each do |name|
      suitability = service.suitabilities.find_or_initialize_by(name: name)

      if suitability.save
        puts "  🟢 Suitability: \"#{name}\" created (id: #{suitability.id})."
      else
        abort("  🔴 Suitability: \"#{name}\" was not created. Exiting. #{suitability.errors.messages}")
      end
    end
  end

  # create taxonomies
  def new_service_taxonomies(service, taxonomies)
    taxonomies&.split(';')&.collect(&:strip)&.each do |taxonomy|
      taxa = service.taxonomies.find_or_initialize_by(name: taxonomy)

      if taxa.save(skip_scout_rebuild: true)
        puts "  🟢 Taxonomy: \"#{taxonomy}\" created (id: #{taxa.id})."
      else
        abort("  🔴 Taxonomy: \"#{taxonomy}\" was not created. Exiting. #{taxa.errors.messages}")
      end
    end
  end

  # when creating a new service we need to check for organisations
  # TODO when doing organisations we also need to create users for them as well!
  def new_service_organisation(organisation_name)
    organisation = Organisation.find_or_initialize_by(name: organisation_name&.strip)

    if organisation.save(skip_mongo_callbacks: true)
      puts "  🟢 Organisation: \"#{organisation.name}\" created (id: #{organisation.id})."
      return organisation
    else 
      abort("  🔴 Organisation: \"#{organisation.name}\" was not created. Exiting. #{organisation.errors.messages}")
    end
  end

  # when creating a new service we add links
  def new_service_links(service, row)
    new_link = service.links.find_or_initialize_by(label: row["links_label"], url: row["links_url"])
    if new_link.save
      puts "  🟢 Link: created (id: #{new_link.id})."
    else
      abort("  🔴 Link: was not created. Exiting. #{new_link.errors.messages}")
    end
  end

  # when creating a new service we add cost options
  def new_service_regular_schedules(service_id, regular_schedule_data)
    # @TODO theres nothing stopping silly opening hours being put in here
    days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday','sunday']
    if regular_schedule_data['scheduled_weekday'].present?
      weekday = days.find_index(regular_schedule_data['scheduled_weekday'].downcase)
    end

    if regular_schedule_data['schedules_opens_at'].to_time.present? && regular_schedule_data['schedules_closes_at'].to_time.present? && !weekday.nil?
      new_regular_schedule = RegularSchedule.new(
        opens_at: regular_schedule_data['schedules_opens_at'].to_time,
        closes_at: regular_schedule_data['schedules_closes_at'].to_time,
        weekday: weekday+1,
        service_id: service_id
      )
      if new_regular_schedule.save
        puts "  🟢 Regular schedule: created (id: #{new_regular_schedule.id})."
      else 
        abort("  🔴 Regular schedule: was not created. Exiting. #{new_regular_schedule.errors.messages}")
      end

    else 
      puts " 👉 Regular schedule: wonky hours."
    end 
  end       

  # when creating a new service we add cost options
  def new_service_cost_option(service, cost_option_data)
    new_cost_option = service.cost_options.find_or_initialize_by(
      option: cost_option_data['cost_option'],
      amount: cost_option_data['cost_amount'],
      cost_type: cost_option_data['cost_type'],
    )
    if new_cost_option.save
      puts "  🟢 Cost option: created (id: #{new_cost_option.id})."
      return new_cost_option
    else 
      abort("  🔴 Cost option: was not created. Exiting. #{new_cost_option.errors.messages}")
    end
  end        

  # when creating a new service we add notes
  def new_service_notes(service, note_data)
    user = User.where(admin: true, admin_users: true)
    if user.exists?
      new_note = service.notes.new(body: note_data, user_id: user.first.id)
      if new_note.save
        puts "  🟢 Note: created (id: #{new_note.id})."
        return new_note.id
      else 
        abort("  🔴 Note: was not created. Exiting. #{new_note.errors.messages}")
      end
    else 
      puts " 👉 Note: not created as no viable admin user found to give credit to."
    end
  end    

  # when creating a new service we add locations
  def new_service_location(service, location_data)
    new_location = service.locations.new(
      name: location_data['location_name'],
      latitude: location_data['location_latitude'],
      longitude: location_data['location_longitude'],
      address_1: location_data['location_address_1'],
      city: location_data['location_city'],
      postal_code: location_data['location_postcode'],
      visible: location_data['location_visible'],
      mask_exact_address: location_data['mask_exact_address'],
      preferred_for_post: location_data['preferred_for_post'],
      skip_mongo_callbacks: true
    )

    if new_location.save
      puts "  🟢 Location: \"#{new_location.name}\" created (id: #{new_location.id})."

      if location_data['location_accessibilities'].present?
        location_accessibilities = location_data['location_accessibilities'].split(';').collect(&:strip)
        location_accessibilities.each do |option|
          new_location.accessibilities.find_or_create_by({name: option.downcase.capitalize})
        end
      end

      return new_location
    else 
      abort("  🔴 Location: \"#{new_location.name}\" was not created. Exiting. #{new_location.errors.messages}")
    end
  end    


  # when creating a new service we add contacts
  def new_service_contact(service, contact_data)
    contact = service.contacts.find_by(email: contact_data['contact_email']&.strip)
    if contact
      puts "  👉 NB: contact for this service already exists so not creating them. \"#{contact_data['contact_email']}\"."
      return contact.id
    else 
      new_contact = service.contacts.new(
        name: contact_data['contact_name']&.strip,
        title: contact_data['contact_title']&.strip,
        visible: contact_data['contact_visible'].present? ? contact_data['contact_visible'] : false,
        email: contact_data['contact_email']&.strip,
        phone: contact_data['contact_phone']&.strip,
      )
      if new_contact.save
        puts "🟢 Contact: \"#{new_contact.name}\" created (id: #{new_contact.id})."
        return new_contact.id
      else 
        abort("🔴 Contact: \"#{new_contact.name}\" was not created. Exiting. #{new_contact.errors.messages}")
      end
    end 
  end


  # check for duplicates in a given column
  def check_is_numeric(csv_data, column_name)
    data = csv_data.select{|item| !item[column_name].nil? }
    non_numeric_values = data.filter{|i| !CSV::Converters[:integer].call(i[column_name]).is_a?(Numeric) }
    naughty_values = non_numeric_values.map{|i| " 👉 \"#{i[column_name]}\"" }.join("\n")
    if non_numeric_values.length > 0
      puts "🔴 Found non numeric data in #{column_name} \n\n#{naughty_values}\n\n"
      return true  
    else  
      return false
    end
  end

  # check booleans are booleans
  def check_is_boolean(csv_data, column_name)
    data = csv_data.select{|item| !item[column_name].nil? }
    non_numeric_values = data.filter{|i| !CSV::Converters[:boolean].call(i[column_name]).is_a?(boolean) }
    naughty_values = non_numeric_values.map{|i| " 👉 \"#{i[column_name]}\"" }.join("\n")
    if non_numeric_values.length > 0
      puts "🔴 Found non boolean data in #{column_name} \n\n#{naughty_values}\n\n"
      return true  
    else  
      return false
    end
  end

  # check for duplicates in a given column
  def check_for_duplicates(csv_data, column_name)
    data = csv_data.select{|item| !item[column_name].nil? }
    value = data.map{|i| i[column_name]}
    duplicates = value.filter{ |e| value.count(e) > 1 }.sort.uniq
    naughty_values = duplicates.map{|i| " 👉 \"#{i}\"" }.join("\n")
    if value.uniq.length != value.length
      puts "🔴 Found some services with the same #{column_name} \n\n#{naughty_values}\n\n"
      return true
    else
      return false
    end
  end


  # Check the required field exists in the data
  def check_required_field_exists(csv_data, column_name)
    data = csv_data.select{|item| !item[column_name].nil? }
    if data.length < csv_data.length
      puts "🔴 Some rows contain empty #{column_name}"
      return true
    else  
      return false
    end
  end

  # name must have import id and vice versa
  def check_name_import_id(csv_data)
    # import_id !import_id_reference
    data = csv_data.select{|item| item['import_id'].present? && item['import_id_reference'].nil? && item['name'].nil?}
    if data.length > 0
      puts "🔴 Import id requires a name field"
      puts data.map{|i| " 👉 \"#{i["import_id"]}\"" }.join("\n")
      return true
    else  
      return false
    end
  end

end
