class CustomField < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates_presence_of :field_type
  belongs_to :custom_field_section

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
