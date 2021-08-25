namespace :bod do
  namespace :custom_fields do

    task :build_initial => :environment do
      custom_fields_yaml = Rails.root.join('lib', 'seeds', 'bod', 'custom_fields.yml')
      custom_field_sections_yaml = YAML::load_file(custom_fields_yaml)
      custom_field_sections_yaml.each do |custom_field_section_yaml|
        custom_field_section = CustomFieldSection.new(
          name: custom_field_section_yaml["name"],
          hint: custom_field_section_yaml["hint"],
          public: custom_field_section_yaml["public"],
          api_public: custom_field_section_yaml["api_public"],
          sort_order: custom_field_section_yaml["sort_order"]
        )
        unless custom_field_section.save
          puts "CustomFieldSection #{custom_field_section.name} failed to save: #{custom_field_section.errors.messages}"
        end

        custom_field_section_yaml["custom_fields"].each do |custom_field_yaml|
          custom_field = CustomField.new(
            key: custom_field_yaml["label"],
            field_type: custom_field_yaml["field_type"],
            options: custom_field_yaml["options"],
            hint: custom_field_yaml["hint"],
            custom_field_section_id: custom_field_section.id
          )
          unless custom_field.save
            puts "CustomField #{custom_field.name} failed to save: #{custom_field.errors.messages}"
          end
        end
      end
    end
  end
end