class OfstedItem < ApplicationRecord

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
    scope :oldest, ->  { order("registration_date ASC") }
    scope :newest, ->  { order("registration_date DESC") }
    scope :oldest_changed, ->  { order("last_change_date ASC") }
    scope :newest_changed, ->  { order("last_change_date DESC") }

end