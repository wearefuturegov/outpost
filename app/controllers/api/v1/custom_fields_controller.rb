class API::V1::CustomFieldsController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
      render json: json_tree(CustomFieldSection.api_public.includes(:custom_fields)).to_json
    end
  
    private
  
    def json_tree(custom_field_sections)
      custom_field_sections.map do |section|
        {
          id: section.id,
          name: section.name,
          hint: section.hint,
          custom_fields: section.custom_fields.map do |field|
            field_hash = {
                id: field.id,
                label: field.label,
                key: field.key,
                hint: field.hint,
                field_type: field.field_type
              }
              field_hash[:options] = process_options(field.options) if field.field_type == 'select'
              field_hash
          end
        }
      end
    end

    def process_options(options_string)
        options_string.split(',').map.with_index(1) do |option, index|
          {
            value: option.strip,
            # key: option.strip.parameterize
          }
        end
      end
  end