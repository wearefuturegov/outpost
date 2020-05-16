class Taxonomy < ApplicationRecord

    has_ancestry

    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies
    
    validates_presence_of :name, uniqueness: true

    def slug
        name.parameterize
    end

end
