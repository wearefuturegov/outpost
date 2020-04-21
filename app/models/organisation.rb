class Organisation < ApplicationRecord
    has_many :services

    has_many :users

    paginates_per 20

    include PgSearch::Model
    pg_search_scope :search, 
      against: [:name], 
      using: {
        tsearch: { prefix: true }
      }

    def display_name
        self.name || "Unnamed organisation #{self.id}"
    end
end