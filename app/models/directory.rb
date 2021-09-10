class Directory < ApplicationRecord
  has_and_belongs_to_many :services
  validates_presence_of :name, :label
  validates_uniqueness_of :name, :label
  # def display_name
  #   name.humanize
  # end

  # def slug
  #   name.parameterize
  # end
end
