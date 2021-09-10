class Directory < ApplicationRecord
  has_and_belongs_to_many :services
  has_and_belongs_to_many :taxonomies
  validates_presence_of :name, :label
  validates_uniqueness_of :name, :label
end
