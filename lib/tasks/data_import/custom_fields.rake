namespace :custom_fields do
  desc 'import custom field from csv file to database'
  task :build_initial => :environment do
    file_path = Rails.root.join('lib', 'seeds', 'custom_fields.csv')
    
    file = File.open(file_path, "r:ISO-8859-1")
    csv_parser = CSV.parse(file, headers: true)

    if (validate_data(csv_parser.select{|item| item['import_id_reference'] != nil}))

      csv_parser.each.with_index do |row, index|
        if row['import_id_reference'] == nil
          custom_field_section = CustomFieldSection.new(
            name: row["name"],
            hint: row["description"],
            public: row["public"],
            api_public: row["api_public"],
            sort_order: row["sort_order"]
          )

          unless custom_field_section.save
            puts "CustomFieldSection #{custom_field_section.name} failed to save: #{custom_field_section.errors.messages}"
          end
        end

        custom_field_array = csv_parser.select{|item| item['import_id_reference'] == row['import_id']} #searching by reference id and gets bunch of items based on condition

        if (!custom_field_array.empty?) #if array is not empty
          custom_field_array.each { |row|
            custom_field = CustomField.new(
              key: row["key"],
              field_type: row["field_type"].capitalize,
              options: row["options"],
              hint: row["description"],
              custom_field_section_id: custom_field_section.id
            )
            
            unless custom_field.save
              puts "CustomField #{custom_field.id} failed to save: #{custom_field.errors.messages}"
            end
          }

        end
      end

    end

  end

  def validate_data(csv_parser_array)

    csv_parser_array.each{ |row|

      if (row["field_type"].nil? || !(CustomField.types.include? row["field_type"].capitalize))
        puts "import has been stopped, there is invalid data ('field_type' must accept one of these values: #{CustomField.types}) -> import_id: #{row['import_id']}"
        return false
      end
    }

    return true
  end
end