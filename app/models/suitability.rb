class Suitability < ApplicationRecord
  has_and_belongs_to_many :services

  validates_presence_of :name

  def display_name
    name.humanize
  end

  def slug
    name.parameterize
  end
end
