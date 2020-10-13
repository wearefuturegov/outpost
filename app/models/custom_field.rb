class CustomField < ApplicationRecord
    validates_presence_of :key, uniqueness: true
    validates_presence_of :field_type
    belongs_to :custom_field_section

    def self.types
        [
            "Text",
            "Number",
            "Checkbox"
        ]
    end

    scope :visible_to, -> (current_user){ current_user.admin ? all : where(public: true) }
end
