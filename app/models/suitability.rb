class Suitability < ApplicationRecord
  has_and_belongs_to_many :services

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
      "Autism",
      "Learning difficulties",
      "Mental health/acquired brain injury",
      "Visual and / or hearing impediment",
      "Physical disabilities",
      "Older people",
      "Dementia"
    ]
  end

end
