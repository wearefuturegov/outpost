namespace :custom_fields do
  desc 'import custom field from csv file to database'
  task :import_from_csv => :environment do
    file_path = Rails.root.join('lib', 'seeds', 'custom_fields.csv')
    
    file = File.open(file_path, "r:ISO-8859-1")
    csv_parser = CSV.parse(file, headers: true)
    csv_parser.each.with_index do |row, index|
      if row['custom_field_section_id'] == nil then
        custom_field_section = CustomFieldSection.new(
          name: row["name"],
          hint: row["hint"],
          public: row["public"],
          api_public: row["api_public"],
          sort_order: row["sort_order"]
        )

        unless custom_field_section.save
          puts "CustomFieldSection #{custom_field_section.name} failed to save: #{custom_field_section.errors.messages}"
        end
      end

      custom_field_array = csv_parser.select{|item| item['custom_field_section_id'] == row['id']} #searching by reference id and gets bunch of items based on condition

      if (!custom_field_array.empty?) then #if array is not empty
        custom_field_array.each { |row|
          custom_field = CustomField.new(
            key: row["key"],
            field_type: row["field_type"],
            options: row["options"],
            hint: row["hint"],
            custom_field_section_id: custom_field_section.id
          )

          unless custom_field.save
            puts "CustomField #{custom_field.name} failed to save: #{custom_field.errors.messages}"
          end
        }

      end
    end
  end
end