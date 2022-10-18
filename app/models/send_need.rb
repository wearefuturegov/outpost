class SendNeed < ApplicationRecord
    has_and_belongs_to_many :services

    validates :name, presence: true, uniqueness: true

    def display_name
        name.humanize
    end

    def slug
        name.parameterize
    end
end
