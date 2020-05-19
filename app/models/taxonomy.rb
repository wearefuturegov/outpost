class Taxonomy < ApplicationRecord

    # has_ancestry
    has_closure_tree order: 'name', dependent: :destroy

    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies
    
    validates_presence_of :name, uniqueness: true

    def slug
        name.parameterize
    end

    scope :top_level, -> { where(parent_id: nil) }

end
