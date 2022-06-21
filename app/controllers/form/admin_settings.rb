# frozen_string_literal: true

class Form::AdminSettings
    include ActiveModel::Model
  
    KEYS = %i(
      outpost_title
      outpost_instance_name
      primary_color
      outpost_logo
    ).freeze
  
    BOOLEAN_KEYS = %i(
      
    ).freeze
  
    UPLOAD_KEYS = %i(
      outpost_logo
    ).freeze
  
    attr_accessor(*KEYS)
  
    validates :primary_color, format: { with: /\A#?(?:[A-F0-9]{3}){1,2}\z/i }

  
    def initialize(_attributes = {})
      super
      initialize_attributes
    end
  
    def save
      return false unless valid?
  
      KEYS.each do |key|
        value = instance_variable_get("@#{key}")
  
        if UPLOAD_KEYS.include?(key) && !value.nil?
        #   upload = SiteUpload.where(var: key).first_or_initialize(var: key)
        #   upload.update(file: value)
        else
          setting = Setting.where(var: key).first_or_initialize(var: key)
          setting.update(value: typecast_value(key, value))
        end
      end
    end
  
    private
  
    def initialize_attributes
      KEYS.each do |key|
        instance_variable_set("@#{key}", Setting.public_send(key)) if instance_variable_get("@#{key}").nil?
      end
    end
  
    def typecast_value(key, value)
      if BOOLEAN_KEYS.include?(key)
        value == '1'
      else
        value
      end
    end
  end