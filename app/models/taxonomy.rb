class Taxonomy < ApplicationRecord
    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies
end
