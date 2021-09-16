class Directory < ApplicationRecord
  has_and_belongs_to_many :services, -> { distinct }
  has_and_belongs_to_many :taxonomies, -> { distinct }
  validates_presence_of :name, :label
  validates_uniqueness_of :name, :label
end
