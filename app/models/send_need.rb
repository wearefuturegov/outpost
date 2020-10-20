class SendNeed < ApplicationRecord
    has_and_belongs_to_many :services

    def display_name
        name.humanize
    end
end
