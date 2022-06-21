# RailsSettings Model
class Setting < RailsSettings::Base
  has_one_attached :outpost_logo
  # cache_prefix { "v1" }

  scope :application do 
    field :outpost_title, default: "Outpost", validates: { presence: true }
    field :outpost_sub_title, default: "Manage your services", validates: { presence: true }
    field :outpost_instance_name, default: "our directory service", validates: { presence: true }
  end

  scope :outpost_theme do
    field :outpost_logo, type: :hash
    field :primary_color, type: :string, default: '#2c2d84'
  end

end
