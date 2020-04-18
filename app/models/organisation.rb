class Organisation < ApplicationRecord
    has_many :services
    accepts_nested_attributes_for :services

    has_many :users

    paginates_per 20

    def display_name
        self.name || "Unnamed organisation #{self.id}"
    end
end