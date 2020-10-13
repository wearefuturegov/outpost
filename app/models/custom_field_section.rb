class CustomFieldSection < ApplicationRecord
    validates_presence_of :name, uniqueness: true

    has_many :custom_fields
    accepts_nested_attributes_for :custom_fields, allow_destroy: true, reject_if: :all_blank
end
