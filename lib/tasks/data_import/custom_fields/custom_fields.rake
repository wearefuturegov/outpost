namespace :import do
  desc 'Import custom field from csv file to database. By default, looks for a file at lib/seeds/custom-fields.csv, or you can pass in a custom file path as an argument'
  task :custom_fields, [:file_path] => :environment do |t, args|
    args.with_defaults(file_path: Rails.root.join('lib', 'seeds', 'custom-fields.csv'))
    
    file = File.open(args.file_path, "r:ISO-8859-1")
    csv_parser = CSV.parse(file, headers: true)

    # doing these before we do anything since they're the most likely things to have to fix
    initial_validation_passed = validate_custom_field_import_ids(csv_parser) && validate_field_types(csv_parser)

    if initial_validation_passed
      puts "🟢 Validation passed, continuing with import 🥁"
      import_sections_and_fields(csv_parser)
    else
      puts "😭 Import will fail, data is not valid, see errors above."
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
      custom_field = CustomField.find_by(key: row["name"]&.strip)
      if custom_field
        puts "🟠 Field: \"#{row["name"]}\" already exists, skipping."
      else
        custom_field = CustomField.new(
          key: row["name"]&.strip,
          field_type: row["field_type"].downcase,
          options: row["field_options"],
          hint: row["hint"],
          custom_field_section_id: section_id
        )
        if custom_field.save
          puts "🟢 Field: \"#{row["name"]}\" created (id: #{custom_field.id})."
        else 
          puts "🟠 Field: \"#{row["name"]}\" failed to save. Continuing with import. #{custom_field.errors.messages}"
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
          name: row["name"]&.strip,
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
  # Returns true if valid, false if not
  def validate_custom_field_import_ids(csv_data)
    data = csv_data.select{|item| item['import_id'].present? }

    # all rows should have import_id set
    if data.length < csv_data.length
      puts "🔴 Some rows contain empty import_id"
      return false
    end

    # no duplicated id's in import_id
    ids = data.map{|i| i['import_id']}
    duplicates = ids.filter{ |e| ids.count(e) > 1 }.sort.uniq
    if ids.uniq.length != ids.length
      puts "🔴 Duplicate import_id's #{duplicates.join(',')}"
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
      puts "🔴 Invalid field_types found. Search for these \"#{matches.join(',')}\"\n  ℹ️ Valid field_types: #{CustomField.types.join(',')}"
      return false
    end

    # if field_type === select ensure options is set (and valid)
    data = csv_data.select{|item| item['field_type'] === "select" && item['field_options'].nil? }
    if data.length > 0 
      naughty_rows = data.map{|i| "  👉  \"#{i["name"]}\"" }.join("\n")
      puts "🔴 Missing field_options for select fields \n#{naughty_rows}"
      return false
    end

    return true
  end
end
