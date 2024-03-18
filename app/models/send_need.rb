class SendNeed < ApplicationRecord
    has_and_belongs_to_many :services

    validates :name, presence: true, uniqueness: true

    paginates_per 20

    def display_name
        name.humanize
    end

    def slug
        name.parameterize
    end

    def self.defaults
        [
            "Autism",
            "Hearing impairment",
            "Visual impairment",
            "Mobility",
            "Cognitive"
        ]
    end
end
