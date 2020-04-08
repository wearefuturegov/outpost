class Organisation < ApplicationRecord
    has_many :services

    paginates_per 20

    def display_name
        self.name || "Unnamed organisation"
    end
end