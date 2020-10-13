class CustomFieldSection < ApplicationRecord
    validates_presence_of :name, uniqueness: true
    has_many :custom_fields
end
