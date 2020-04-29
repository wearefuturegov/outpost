class Accessibility < ApplicationRecord
    has_and_belongs_to_many :locations

    def display_name
        name.humanize
    end

end
