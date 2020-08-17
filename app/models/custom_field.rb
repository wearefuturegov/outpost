class CustomField < ApplicationRecord
    validates_presence_of :key, uniqueness: true
    validates_presence_of :field_type

    def self.types
        [
            "Text",
            "Number",
            "Checkbox"
        ]
    end
end
