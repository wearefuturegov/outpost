class CustomField < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates_presence_of :field_type
  belongs_to :custom_field_section, counter_cache: :custom_fields_count

  def self.types
    [
      "Text",
      "Number",
      "Checkbox",
      "Select",
      "Date"
    ]
  end
end
