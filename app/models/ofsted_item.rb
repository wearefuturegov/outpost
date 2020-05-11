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

end