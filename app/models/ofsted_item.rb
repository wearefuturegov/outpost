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

  # sort scopes
  scope :oldest, ->  { reorder("registration_date ASC") }
  scope :newest, ->  { reorder("registration_date DESC") }
  scope :oldest_changed, ->  { reorder("last_change_date ASC") }
  scope :newest_changed, ->  { reorder("last_change_date DESC") }

  def display_name
    setting_name || provider_name
  end
end