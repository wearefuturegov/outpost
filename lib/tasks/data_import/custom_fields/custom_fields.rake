namespace :import do
  desc 'Import custom field from csv file to database. By default, looks for a file at lib/seeds/custom-fields.csv, or you can pass in a custom file path as an argument'
  task :custom_fields, [:file_path] => :environment do |t, args|
    args.with_defaults(file_path: Rails.root.join('lib', 'seeds', 'custom-fields.csv'))
    
    file = File.open(args.file_path, "r:ISO-8859-1")
    csv_parser = CSV.parse(file, headers: true)

    # doing these before we do anything since they're the most likely things to have to fix
    initial_validation_passed = validate_custom_field_import_ids(csv_parser) && validate_field_types(csv_parser)

    if initial_validation_passed
      Rails.logger.info("🟢 Validation passed, continuing with import 🥁")
      import_sections_and_fields(csv_parser)
    else
      Rails.logger.info("😭 Import will fail, data is not valid, see errors above.")
    end
  end


  # Do the import
  def import_sections_and_fields(csv_data)
    csv_data.each do |row|
      # Skip until we get to a row containing a custom field section
      next unless row['import_id_reference'].nil?

      section_id = import_section(row)

      # Once the section is saved, go to import the custom fields in that section
      if section_id
        field_rows = csv_data.select{|item| item['import_id_reference'] === row['import_id']}
        import_fields(section_id, field_rows)
      end
    end
  end


  # import the fields for the set section
  def import_fields(section_id, field_rows)
    field_rows.each do | row |
      custom_field = CustomField.find_by(key: row["name"]&.strip)
      if custom_field
        Rails.logger.info("🟠 Field: \"#{row["name"]}\" already exists, skipping.")
      else
        custom_field = CustomField.new(
          key: row["name"]&.strip,
          field_type: row["field_type"].downcase,
          options: row["field_options"],
          hint: row["hint"],
          custom_field_section_id: section_id
        )
        if custom_field.save
          Rails.logger.info("🟢 Field: \"#{row["name"]}\" created (id: #{custom_field.id}).")
        else
          Rails.logger.info("🟠 Field: \"#{row["name"]}\" failed to save. Continuing with import. #{custom_field.errors.messages}")
        end 
      end
    end
  end


  # Import custom field section
  # Creates a new custom field section unless it already exists
  # Returns the id for the section, or false if the row is for a field rather
  # than a section.
  def import_section(row)
    # If the import_id_reference is empty, it's a section. Otherwise it's a
    # field, so we don't import it here.
    return false unless row['import_id_reference'].nil?

    custom_field_section = CustomFieldSection.find_or_initialize_by(name: row["name"]&.strip)

    if custom_field_section.persisted?
      Rails.logger.info("🟠 Section: \"#{row["name"]}\" already exists, assigning any fields to the existing section (id: #{custom_field_section.id}).")
      return custom_field_section.id
    end

    section_params = {
      hint: row["hint"],
      public: row["section_visible_to_community_users"],
      api_public: row["section_expose_in_public_api"],
      sort_order: row["section_sort_order"]
    }

    if custom_field_section.update(section_params)
      Rails.logger.info("🟢 Section: \"#{row["name"]}\" created (id: #{custom_field_section.id}).")
    else
      abort("🔴 Section: \"#{row["name"]}\" was not created. Aborting. #{custom_field_section.errors.messages}")
    end

    return custom_field_section.id
  end

  # General id related validation
  # Returns true if valid, false if not
  def validate_custom_field_import_ids(csv_data)
    data = csv_data.select{|item| item['import_id'].present? }

    # all rows should have import_id set
    if data.length < csv_data.length
      Rails.logger.info("🔴 Some rows contain empty import_id")
      return false
    end

    # no duplicated id's in import_id
    ids = data.map{|i| i['import_id']}
    duplicates = ids.filter{ |e| ids.count(e) > 1 }.sort.uniq
    if ids.uniq.length != ids.length
      Rails.logger.info("🔴 Duplicate import_id's #{duplicates.join(',')}")
      return false
    end

    return true
  end

  # Validate field types against custom fields model
  # Note this assumes that other checks have passed - eg import_ids etc 
  # Returns true if there are no errors, or false if there are errors
  def validate_field_types(csv_data)
    # check field_type is a valid string
    data = csv_data.select{|item| item['field_type'].present? }
    field_types = data.map{|row| row['field_type']}.uniq.map(&:downcase)
    matches = field_types - CustomField.types.map(&:downcase)
    if matches.length > 0 
      Rails.logger.info("🔴 Invalid field_types found. Search for these \"#{matches.join(',')}\"\n  ℹ️ Valid field_types: #{CustomField.types.join(',')}")
      return false
    end

    # if field_type === select ensure options is set (and valid)
    data = csv_data.select{|item| item['field_type'] === "select" && item['field_options'].nil? }
    if data.length > 0 
      naughty_rows = data.map{|i| "  👉  \"#{i["name"]}\"" }.join("\n")
      Rails.logger.info("🔴 Missing field_options for select fields \n#{naughty_rows}")
      return false
    end

    return true
  end
end
