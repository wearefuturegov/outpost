class OfstedItem < ApplicationRecord
  has_paper_trail

  has_one :service

  include Discard::Model
  
  include PgSearch::Model
  pg_search_scope :search, 
      against: [
          :provider_name,
          :setting_name,
          :reference_number
      ], 
      using: {
          tsearch: { prefix: true }
      }


  filterrific(
    default_filter_params: { sorted_by: "name_asc"},
    available_filters: [
      :sorted_by,
      :with_status,
      :with_provision,
      :search
    ],
  )

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^recent/
      order("last_change_date desc")
    when /^name_/
      order("LOWER(ofsted_items.setting_name) #{direction} NULLS LAST")
    when /^created_at_/
      order("registration_date #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_status, -> (registration_status) {
    where('lower(registration_status) = ?', registration_status.downcase)
  }

  scope :with_provision, -> (provision_type) {
    where('lower(provision_type) = ?', provision_type.downcase)
  }

  def self.options_for_with_provision
    [
      ["All provision types", ""],
      ["Home Childcarer"],
      ["Childcare on Non Domestic Premises"],
      ["Childminder"],
      ["Childcare on Domestic Premises"],
      ["Registered Person Provision"]
    ]
  end

  def self.options_for_sorted_by
    [
      ["Recently updated", "recent"],
      ["A-Z", "name_asc"],
      ["Z-A", "name_desc"],
      ["Oldest added", "created_at_asc"],
      ["Newest added", "created_at_desc"]
    ]
  end

  def self.options_for_with_status
    [
      ["All statuses", ""],
      ["Active", "active"],
      ["Cancelled", "cancelled"],
      ["Proposed", "proposed"],
      ["Inactive", "inactive"],
      ["Resigned", "resigned"],
      ["Refused", "refused"],
      ["Suspended", "suspended"]
    ]
  end

  def display_name
    setting_name || provider_name
  end

  # fields we don't care about for version history purposes
  def ignorable_fields
    ["status", "updated_at", "created_at", "discarded_at"]
  end
  
end