class CustomField < ApplicationRecord
  before_validation :slugify_key
  
  validates :key, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "must be lowercase, numbers, and dashes only" }
  validates :label, presence: true, uniqueness: true
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

  private

  def slugify_key
    self.key = key.to_s.parameterize if key.present?
  end


end
