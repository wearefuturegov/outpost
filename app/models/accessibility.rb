class Accessibility < ApplicationRecord
    has_and_belongs_to_many :locations

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
            "Accessible toilet facilities",
            "Hearing loop",
            "Car parking",
            "Changing facilities",
            "British sign language (bsl)",
            "Disabled car parking space",
            "Hoist",
            "Baby changing facilities",
            "Parking nearby",
            "Bus stop nearby",
            "Building has lift",
            "Wheelchair accessible entrance",
            "Partial wheelchair access"
        ]
    end

end
