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

  def display_special_consideration
    case special_consideration
    when "ANON"
      "Anonymity requested"
    when "WREF"
      "Womens refuge"
    when "MOD"
      "Ministry of Defense"
    else
      special_consideration
    end
  end

  def display_registration_status
    human_readable_registration_status(registration_status)
  end

  def human_readable_registration_status(abbreviated_status)
    case abbreviated_status
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
      abbreviated_status
    end
  end

  def human_readable_register(abbreviated_register)
    case abbreviated_register
    when "EYR"
      "Early Years Register"
    when "CCR"
      "Compulsory Childcare Register "
    when "VCR"
      "Voluntary Childcare register"
    else
      abbreviated_register
    end
  end

  def display_provision_type
    human_readable_provision_type(provision_type)
  end

  def human_readable_provision_type(abbreviated_provision)
    case abbreviated_provision
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
      abbreviated_provision
    end
  end

  def human_readable_childcare_period(abbreviated_period)
    case abbreviated_period
    when "2HPD"
      "2 hours or more per day"
    when "3HPD"
      "3 hours or more per day"
    when "4HPD"
      "4 hours or more per day"
    when "45WY"
      "45 weeks or more per year"
    when "5DWK"
      "5 days or more per week"
    when "ALYR"
      "All year round"
    when "OVNT"
      "Overnight"
    when "SCHO"
      "School holiday only"
    when "SCTO"
      "School term only"
    when "WDAL"
      "Weekday all day"
    when "WDAM"
      "Weekday AM"
    when "WDAS"
      "Weekday after school"
    when "WDBS"
      "Weekday before school"
    when "WDPM"
      "Weekday PM"
    when "WEND"
      "Weekend"
    else
      abbreviated_period
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