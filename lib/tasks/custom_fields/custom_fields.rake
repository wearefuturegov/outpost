namespace :custom_fields do
  desc 'import custom field from csv file to database'
  task :import => :environment do
    file_path = Rails.root.join('lib', 'seeds', 'custom-fields.csv')
    
    file = File.open(file_path, "r:ISO-8859-1")
    csv_parser = CSV.parse(file, headers: true)

    # doing these before we do anything since they're the most likely things to have to fix
    initial_validation_has_errors = (validate_import_ids(csv_parser) || validate_field_types(csv_parser))

    if initial_validation_has_errors 
      puts "😭 Import will fail, data is not valid, see errors above."
    else 
      puts "🟢 Validation passed, continuing with import 🥁"
      import_sections_and_fields(csv_parser)
    end

  end


  # Do the import
  def import_sections_and_fields(csv_data)
    csv_data.each.with_index do |row, index|
      section_id = import_sections(row)
      if section_id
        field_rows = csv_data.select{|item| item['import_id_reference'] === row['import_id']}
        field_rows.length > 0 if import_fields(section_id, field_rows)
      end
    end
  end


  # import the fields for the set section
  def import_fields(section_id, field_rows)
    field_rows.each do | row |
      custom_field = CustomField.where(key: row["name"])
      if custom_field.exists?
        puts "🟠 Field: \"#{row["name"]}\" already exists, skipping."
      else
        custom_field = CustomField.new(
          key: row["name"],
          field_type: row["field_type"].downcase,
          options: row["field_options"],
          hint: row["hint"],
          custom_field_section_id: section_id
        )
        if custom_field.save
          puts "🟢 Field: \"#{row["name"]}\" created (id: #{custom_field.id})."
        else 
          puts "🟠 Field: \"#{row["name"]}\" failed to save. Continuing with import.  #{custom_field.errors.messages}"
        end 
      end
    end
  end


  # Import sections
  # if section exists it will continue with the fields
  # returns id for the section
  def import_sections(row)
    if row['import_id_reference'] == nil
      custom_field_section = CustomFieldSection.where(name: row["name"])
      if custom_field_section.exists?
        if custom_field_section.count > 1
          abort("🔴 Section: \"#{row["name"]}\" exists multiple times, not safe to continue. Aborting.")
        else 
          custom_field_section_id = CustomFieldSection.where(name: row["name"]).take.id
          puts "🟠 Section: \"#{row["name"]}\" already exists, assigning any fields to the existing section (id: #{custom_field_section_id})."
        end
      else
        new_custom_field_section = CustomFieldSection.new(
          name: row["name"],
          hint: row["hint"],
          public: row["section_visible_to_community_users"],
          api_public: row["section_expose_in_public_api"],
          sort_order: row["section_sort_order"]
        )
        if new_custom_field_section.save
          custom_field_section_id = new_custom_field_section.id
          puts "🟢 Section: \"#{row["name"]}\" created (id: #{custom_field_section_id})."
        else 
          abort("🔴 Section: \"#{row["name"]}\" was not created. Aborting. #{new_custom_field_section.errors.messages}")
        end
    end
    return custom_field_section_id
  end
  end

  # General id related validation
  def validate_import_ids(csv_data)
    errors = false

    # no row should have empty import_id and import_id_reference
    data = csv_data.select{|item| item['import_id'].nil? && item['import_id_reference'].nil? }
    if data.length > 0 
      puts "🔴 Some rows contain empty import_id and import_id reference"
      errors = true
    end

    # no row should have both import_id and import_id_reference set
    data = csv_data.select{|item| !item['import_id'].nil? && !item['import_id_reference'].nil? }
    if data.length > 0 
      puts "🔴 Some rows have both import_id and import_id reference set"
      errors = true
    end

    # no duplicated id's in import_id
    data = csv_data.select{|item| !item['import_id'].nil? }
    ids = data.map{|i| i['import_id']}
    if ids.uniq.length != ids.length
      puts "🔴 Duplicate import_id's"
      errors = true
    end

    return !!errors
  end

  # Validate field types against custom fields model
  # Note this assumes that other checks have passed - eg import_ids etc 
  def validate_field_types(csv_data)
    errors = false

    # check field_type is a valid string
    data = csv_data.select{|item| !item['field_type'].nil? }
    field_types = data.map{|i| i['field_type']}.uniq.map(&:downcase)
    matches = field_types - CustomField.types.map(&:downcase)
    if matches.length > 0 
      puts "🔴 Invalid field_types found. Search for these \"#{matches.join(',')}\"\n  ℹ️ Valid field_types: #{CustomField.types.join(',')}"
      errors = true
    end

    # if field_type === select ensure options is set (and valid)
    data = csv_data.select{|item| item['field_type'] === "select" && item['field_options'].nil? }
    if data.length > 0 
      naughty_rows = data.map{|i| "  👉  \"#{i["name"]}\"" }.join("\n")
      puts "🔴 Missing field_options for select fields \n#{naughty_rows}"
      errors = true
    end

    return !!errors
  end

end