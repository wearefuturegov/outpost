class Organisation < ApplicationRecord
    has_many :services
    has_many :users

    paginates_per 20

    # filter scopes
    scope :only_with_services, ->  { joins(:services) }
    scope :only_with_users, ->  { joins(:users) }
    scope :only_without_services, ->  { left_joins(:services).where(services: {id: nil}) }
    scope :only_without_users, ->  { left_joins(:users).where(users: {id: nil}) }

    # sort scopes
    scope :oldest, ->  { order("updated_at ASC") }
    scope :newest, ->  { order("updated_at DESC") }
    scope :alphabetical, ->  { order(name: :ASC) }
    scope :reverse_alphabetical, ->  { order(name: :DESC) }

    include PgSearch::Model
    pg_search_scope :search, 
      against: [:id, :name], 
      using: {
        tsearch: { prefix: true }
      }

    def display_name
      if self.name.present?
        name
      else
        "Unnamed organisation #{self.id}"
      end
    end
end