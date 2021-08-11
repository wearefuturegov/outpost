class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations
  has_and_belongs_to_many :accessibilities

  attr_accessor :skip_postcode_validation
  validates :postal_code, presence: true,  unless: :skip_postcode_validation
  validate :postal_code_is_valid,  unless: :skip_postcode_validation

  #before_validation :geocode
  #geocoded_by :postal_code

  paginates_per 20

  attr_accessor :skip_mongo_callbacks
  after_commit :update_index, if: -> { skip_mongo_callbacks != true }

  def postal_code_is_valid
    parsed = UKPostcode.parse(postal_code)
    unless parsed.full_valid?
      errors.add(:base, :invalid_postcode)
    end
  end

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :name, :address_1, :city, :postal_code, :state_province], 
    using: {
      tsearch: { prefix: true }
    }

  filterrific(
    default_filter_params: { sorted_by: "name_asc"},
    available_filters: [
      :sorted_by,
      :search,
      :services
    ],
  )

  scope :services, ->(value) { 
    case value.to_s
    when "with"
      joins(:services)
    when "without"
      left_joins(:services).where(services: {id: nil})
    end
  }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^name_/
      order("LOWER(locations.name) #{direction} NULLS LAST")
    end
  }

  def self.options_for_sorted_by
    [
      ["Z-A", "name_desc"],
      ["A-Z", "name_asc"],
    ]
  end

  def self.options_for_services
    [
      ["All", "false"],
      ["Only with services", "with"],
      ["Only without services", "without"]
    ]
  end



  def display_name
    if name.present?
      name
    elsif address_1.present?
      address_1
    else
      "Unnamed location #{id}"
    end
  end

  def one_line_address
    array = []
    array.push(name) if name.present?
    array.push(address_1) if address_1.present?
    array.push(city) if city.present?
    array.push(postal_code) if postal_code.present?
    array.join(", ")
  end

  def geometry
    {
      type: "Point",  
      coordinates: [longitude.to_f, latitude.to_f]
    }
  end

  private

  def should_geocode?
    postcode_changed_or_lat_long_blank && Rails.env.production?
  end

  def postcode_changed_or_lat_long_blank
    postal_code_changed? || latitude.blank? || longitude.blank?
  end

  def checkbox_attributes
    {
      name: display_name,
      one_line_address: one_line_address
    }
  end

  def update_index
    UpdateIndexLocationsJob.perform_later(self)
  end
end