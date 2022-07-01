namespace :services do
    desc 'import services from csv file to database'
    task :import => :environment do
      file_path = Rails.root.join('lib', 'seeds', 'services.csv')
      
      file = File.open(file_path, "r:ISO-8859-1")
      csv_parser = CSV.parse(file, headers: true,
      skip_blanks: true,
      skip_lines: /^(?:,\s*)+$/)
  
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
            child_rows.length > 0 if append_data_to_all_row_types(service_id, row)
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
                value = !value.nil? ? value.split(';').join(',') : ''
              when "date"
                value = value&.strip&.to_date.present? ? value&.strip&.to_date : ''
            end

            if value.present?
              state = "created"
              new_service_meta_exists = ServiceMeta.where(service_id: service_id)
              if new_service_meta_exists
                state = "updated"
              end
              new_service_meta = ServiceMeta.find_or_initialize_by(service_id: service_id).update(
                key: key,
                value: value
              )
              if new_service_meta
                puts "  🟢 Service meta: #{state}"
              else 
                abort("  🔴 Service meta: was not created. Exiting. #{new_service_meta.errors.messages}")
              end
            end
          end
        end
      end
    end

    def import_parent_service(row)
        valid_headers = ['import_id','import_id_reference','name','description','organisation','url','approved','visible_from','visible_to','visible','needs_referral','min_age','max_age','notes','service_taxonomies','contact_name','contact_title','contact_visible','contact_email','contact_phone','location_name','location_latitude','location_longitude','location_address_1','location_city','location_postcode','location_visible','mask_exact_address','preferred_for_post','location_accessibilities','free','cost_option','cost_amount','cost_type','temporarily_closed','schedules_opens_at','schedules_closes_at','scheduled_weekday','links_label','links_url','labels','suitabilities','is_local_offer','send_needs_support','support_description','recent_send_report','outcomes','recent_send_training','parental_involvement','information_sharing','environment_accessibility','how_to_start','future_plans'];

        if row['import_id_reference'] == nil 
            service = Service.where(name: row["name"]&.strip)
            if service.exists?
              if service.count > 1
                abort("🔴 Service: \"#{row["name"]}\" exists multiple times in outpost, not safe to continue. Aborting.")
              else 
                service_id = Service.where(name: row["name"]&.strip).take.id
                puts "🟠 Service: \"#{row["name"]}\" already exists, skipping anything to do with this service (id: #{service_id})."
              end
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
                organisation_id: new_service_organisation(row['organisation']),
                temporarily_closed: row["temporarily_closed"],
                skip_mongo_callbacks: true
              )
              if new_service.save
                service_id = new_service.id
                puts "🟢 Service: \"#{row["name"]}\" created (id: #{service_id})."
                puts " 👉 Now adding more to it"

                # deliminated data
                service_taxonomies = row['service_taxonomies']&.strip
                if service_taxonomies.present? && !service_taxonomies.nil?  
                  taxonomies_for_service = new_service_taxonomies(service_id, service_taxonomies) 
                  Service.update(service_id, :taxonomies => taxonomies_for_service, :skip_mongo_callbacks => true)
                end 

                labels = row['labels']&.strip
                if labels.present? && !labels.nil?  
                  labels_for_service = row['labels']&.strip.split(';').collect(&:strip).reject(&:empty?).uniq
                  Service.update(service_id, :label_list => labels_for_service, :skip_mongo_callbacks => true)
                end 

                suitabilities = row['suitabilities']&.strip
                if suitabilities.present? && !suitabilities.nil?  
                  suitabilities_for_service = new_service_suitabilities(service_id, suitabilities) 
                  Service.update(service_id, :suitability_ids => suitabilities_for_service, :skip_mongo_callbacks => true)
                end 


                # SEND
                if row['is_local_offer'].present? && row['support_description'].present?
                  new_service_send_needs(service_id, row)
                end 
                # send_needs_support
                if !row['send_needs_support'].nil?
                  send_needs_support_for_service = new_service_send_needs_suitabilities(service_id, row['send_needs_support'])
                  Service.update(service_id, :send_need_ids => send_needs_support_for_service, :skip_mongo_callbacks => true)
                end
                

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

        # contacts
        # TODO send only info contacts needs
        if row["contact_name"].present? && row["contact_email"].present? && row["contact_phone"].present?
          new_service_contact(service_id, row)
        else
          # @TODO this validation should probaly go higher up
          puts "  🟠 No contact was created as no name or email was present "
        end

        # notes
        if row["notes"].present?
          new_service_notes(service_id, row["notes"])
        end

        # location
        if row["location_postcode"].present?
          # @TODO this validation should go higher up
          location_for_service = new_service_location(row) 
          Service.update(service_id, :locations => [location_for_service], :skip_mongo_callbacks => true)
        end

        # costs
        if row["cost_option"].present? || row["cost_amount"].present? || row["cost_type"].present? 
          # @TODO this validation should go higher up
          new_service_cost_option(service_id, row)
        end

        # schedule
        if row["schedules_opens_at"].present? && row["schedules_closes_at"].present? && row["scheduled_weekday"].present? 
          # @TODO this validation should go higher up
          new_service_regular_schedules(service_id, row)
        else 
          puts "  🟠 No schedule was created as not all fields contained data"
        end

        # links
        if row["links_label"].present? && row["links_url"].present?
          # @TODO this validation should go higher up
          new_service_links(service_id, row)
        end


    end

    # create send needs
    
    def new_service_send_needs(service_id, send_needs_data)
      
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

    # add send_needs_suitabilities into send_needs_services
    def new_service_send_needs_suitabilities(service_id, send_needs_support)
      send_needs_support = send_needs_support.split(';').collect(&:strip).reject(&:empty?).uniq
      puts send_needs_support.inspect
      sids = []
      send_needs_support.map do | t |
          send_need = SendNeed.where(name: t)
          if send_need.exists?
            puts "  🟠 The send need \"#{t}\" already exists, adding it to the service (id: #{send_need.take.id})"
            sids << send_need.take.id
          else
            new_send_need = SendNeed.create(
              name: t,
            )
            if new_send_need.save
              puts "  🟢 Send need: \"#{new_send_need.name}\" created (id: #{new_send_need.id})."
              sids << new_send_need.id
            else 
              abort("  🔴 Send need: \"#{new_send_need.name}\" was not created. Exiting. #{new_send_need.errors.messages}")
            end
          end
      end 
      return sids
    end

    # create suitabilities
    def new_service_suitabilities(service_id, suitabilities)
      suitabilities = suitabilities.split(';').collect(&:strip).reject(&:empty?).uniq
      sids = []
        suitabilities.map do | t |
          suitability = Suitability.where(name: t)
          if suitability.exists?
            puts "  🟠 The suitability \"#{t}\" already exists, adding it to the service"
            sids << suitability.take.id
          else
            new_suitability = Suitability.create(
              name: t,
            )
            if new_suitability.save
              puts "  🟢 Suitability: \"#{new_suitability.name}\" created (id: #{new_suitability.id})."
              sids << new_suitability.id
            else 
              abort("  🔴 Suitability: \"#{new_suitability.name}\" was not created. Exiting. #{new_suitability.errors.messages}")
            end
          end
      end 
      return sids
    end

    # create taxonomies
    def new_service_taxonomies(service_id, taxonomies)
      taxonomies = taxonomies.split(';').collect(&:strip).reject(&:empty?).uniq
      tids = []
        taxonomies.map do | t |
          taxonomy = Taxonomy.where(name: t)
          if taxonomy.exists?
            puts "  🟠 The taxonomy \"#{t}\" already exists, adding it to the service"
            tids << taxonomy.take
          else
            new_taxonomy = Taxonomy.create(
              name: t,
              skip_mongo_callbacks: true
            )
            if new_taxonomy.save
              puts "  🟢 Taxonomy: \"#{new_taxonomy.name}\" created (id: #{new_taxonomy.id})."
              tids << new_taxonomy
            else 
              abort("  🔴 Taxonomy: \"#{new_taxonomy.name}\" was not created. Exiting. #{new_taxonomy.errors.messages}")
            end
          end
      end 
      return tids
    end

    # when creating a new service we need to check for organisations
    # TODO when doing organisations we also need to create users for them as well!
    def new_service_organisation(organisation_name)
      organisation = Organisation.where(name: organisation_name&.strip)
      if organisation.exists?
          return organisation.take.id
      else 
        new_organisation = Organisation.new(
          name: organisation_name&.strip,
          skip_mongo_callbacks: true
        )
        if new_organisation.save
          organisation_id = new_organisation.id
          puts "  🟢 Organisation: \"#{organisation_name}\" created (id: #{organisation_id})."
          return new_organisation.id
        else 
          abort("  🔴 Organisation: \"#{organisation_name}\" was not created. Exiting. #{new_organisation.errors.messages}")
        end
      end
    end

    # when creating a new service we add links
    def new_service_links(service_id, links_data)
      # @TODO theres nothing stopping silly opening hours being put in here
    
        new_link = Link.new(
          label: links_data["links_label"],
          url: links_data["links_url"],
          service_id: service_id
        )
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
    def new_service_cost_option(service_id, cost_option_data)
        # @TODO validate cost_option properly
        new_cost_option = CostOption.new(
          option: cost_option_data['cost_option'],
          amount: cost_option_data['cost_amount'],
          cost_type: cost_option_data['cost_type'],
          service_id: service_id
        )
        if new_cost_option.save
          puts "  🟢 Cost option: created (id: #{new_cost_option.id})."
          return new_cost_option
        else 
          abort("  🔴 Cost option: was not created. Exiting. #{new_cost_option.errors.messages}")
        end
    end        

    # when creating a new service we add notes
    def new_service_notes(service_id, note_data)
      user = User.where(admin: true, admin_users: true)
      if user.exists?
        new_note = Note.new(
          service_id: service_id,
          body: note_data,
          user_id: user.first.id
        )
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
    def new_service_location(location_data)
          new_location = Location.new(
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

          if location_data['location_accessibilities'].present?
            location_accessibilities = location_data['location_accessibilities'].split(';').collect(&:strip).reject(&:empty?).uniq
            location_accessibilities.each do |option|
              new_location.accessibilities << Accessibility.find_or_initialize_by({name: option.downcase.capitalize})
            end
          end

          if new_location.save
            puts "  🟢 Location: \"#{new_location.name}\" created (id: #{new_location.id})."
            return new_location
          else 
            abort("  🔴 Location: \"#{new_location.name}\" was not created. Exiting. #{new_location.errors.messages}")
          end
    end    
    
    
    # when creating a new service we add contacts
    def new_service_contact(service_id, contact_data)
        contact = Contact.where(email: contact_data['contact_email'], service_id: service_id)
        if contact.exists?
          puts "  👉 NB: contact for this service already exists so not creating them. \"#{contact_data['contact_email']}\"."
          return contact.take.id
        else 
          new_contact = Contact.new(
            service_id: service_id,
            name: contact_data['contact_name']&.strip,
            title: contact_data['contact_title']&.strip,
            visible:  contact_data['contact_visible'].present? ? contact_data['contact_visible'] : false,
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
      data = csv_data.select{|item| !item['import_id'].nil? && item['import_id_reference'].nil? }.filter{|f| f['name'].nil?}
      if data.length > 0
        puts "🔴 Import id requires a name field"
        puts data.map{|i| " 👉 \"#{i["import_id"]}\"" }.join("\n")
        return true
      else  
        return false
      end
    end
  
   
  
  end