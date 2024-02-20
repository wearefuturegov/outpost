# RailsSettings Model
# This implementation is heavily influenced by mastodon's use of the rails-settings-cached gem
# id 
# var eg outpost_title used to refer to the setting
# value value for the field
# created_at
# updated_at

class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  APPLICATION = %w[
    outpost_title
    outpost_sub_title
    outpost_instance_name
  ]

  FEATURES = %w[
    feature_wysiwyg
    feature_disabled
    feature_enabled
    feature_never_set
  ]

  OUTPOST_THEME = %w[
    outpost_logo
    primary_color
    outpost_logo_height
    outpost_logo_height_mobile
  ]

  scope :application do 
    field :outpost_title, type: :string, default: "Outpost", validates: { presence: true }
    field :outpost_sub_title, type: :string, default: "Manage your services", validates: { presence: true }
    field :outpost_instance_name, type: :string, default: "our directory service", validates: { presence: true }
  end

  scope :features do 
    field :feature_wysiwyg, type: :boolean, default: false
  end

  scope :outpost_theme do
    field :outpost_logo, type: :hash
    field :primary_color, type: :string, default: '#2c2d84'
    field :outpost_logo_height, type: :int, default: '45'
    field :outpost_logo_height_mobile, type: :int, default: '40'
  end

  class << self
    # Returns keys for all active features including those not yet or ever set in the database
    def active_features
      active_features = []
      defined_featured_settings = Setting.defined_fields.group_by { |field| field[:scope] }[:features]
      set_featured_settings = Setting.all.select { |setting| self::FEATURES.include?(setting.var) }
      
      active_features.concat(defined_featured_settings.map {|field| field[:key] if field[:default] == true}.compact)
      active_features.concat(set_featured_settings.map {|field| field.var if field.value == true}.compact)
    end

  end 

end
