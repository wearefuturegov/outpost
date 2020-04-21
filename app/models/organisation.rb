class Organisation < ApplicationRecord
    has_many :services
    has_many :users

    paginates_per 20

    # filter scopes
    scope :only_with_services, ->  { joins(:services) }
    scope :only_with_users, ->  { joins(:users) }
    scope :only_without_services, ->  { left_joins(:services).where(services: {id: nil}) }
    scope :only_without_users, ->  { left_joins(:users).where(users: {id: nil}) }

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