class Taxonomy < ApplicationRecord

    has_ancestry
    
    validates_presence_of :name, uniqueness: true

    def slug
        name.parameterize
    end

end
