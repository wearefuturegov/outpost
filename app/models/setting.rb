# RailsSettings Model
# This implementation is heavily influenced by mastodon's use of the rails-settings-cached gem
# id 
# var eg outpost_title used to refer to the setting
# value value for the field
# created_at
# updated_at

class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  scope :application do 
    field :outpost_title, type: :string, default: "Outpost", validates: { presence: true }
    field :outpost_sub_title, type: :string, default: "Manage your services", validates: { presence: true }
    field :outpost_instance_name, type: :string, default: "our directory service", validates: { presence: true }
  end

  scope :outpost_theme do
    field :outpost_logo, type: :hash
    field :primary_color, type: :string, default: '#2c2d84'
    field :outpost_logo_height, type: :int, default: '45'
    field :outpost_logo_height_mobile, type: :int, default: '40'
  end

end
