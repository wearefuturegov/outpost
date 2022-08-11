class Accessibility < ApplicationRecord
    has_and_belongs_to_many :locations

    validates :name, presence: true, uniqueness: true

    def display_name
        name.humanize
    end

    def slug
        name.parameterize
    end

end
