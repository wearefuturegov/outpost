class OfstedItem < ApplicationRecord
  has_paper_trail

  has_many :services

  include Discard::Model
  
  include PgSearch::Model
  pg_search_scope :search, 
      against: [
          :provider_name,
          :setting_name,
          :reference_number,
          :rp_reference_number
      ], 
      using: {
          tsearch: { prefix: true }
      }


  filterrific(
    default_filter_params: { sorted_by: "name_asc", with_status: "ACTV"},
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
      order("LOWER(ofsted_items.setting_name) #{direction}, LOWER(ofsted_items.provider_name) #{direction}")
    when /^created_at_/
      order("created_at #{direction}")
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
      ["Home childcarer", "HCR"],
      ["Childcare on non-domestic premises", "CCN"],
      ["Childminder", "CMR"],
      ["Childcare on domestic premises", "CCD"],
      ["Registered Person Provision", "RPP"]
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
      ["Active", "ACTV"],
      ["Cancelled", "CANC"],
      ["Proposed", "PROP"],
      ["Inactive", "INAC"],
      ["Resigned", "RESG"],
      ["Refused", "REFU"],
      ["Suspended", "SUSP"]
    ]
  end

  def display_name
    if setting_name.present?
      setting_name
    elsif provider_name.present?
      provider_name
    else
      "Unnamed setting"
    end
  end

  def display_registration_status
    case registration_status
    when "ACTV"
      "Active"
    when "CANC"
      "Cancelled"
    when "PROP"
      "Proposed"
    when "INAC"
      "Inactive"
    when "RESG"
      "Resigned"
    when "SUSP"
      "Suspended"
    else
      registration_status
    end
  end

  def display_provision_type
    case provision_type
    when "CMR"
      "Childminder"
    when "CCD"
      "Childcare on domestic premises"
    when "CCN"
      "Childcare on non-domestic premises"
    when "HCR"
      "Home childcarer"
    when "RPP"
      "Registered person provision"
    else
      provision_type
    end
  end

  def unapproved_fields
    changed_fields = []
    versions.last.changeset.map do |key, value|
      unless ignorable_fields.include?(key)
        changed_fields << key.humanize
      end
    end
    changed_fields
  end

  # fields we don't care about for version history purposes
  def ignorable_fields
    ["status", "updated_at", "created_at", "discarded_at"]
  end
  
end