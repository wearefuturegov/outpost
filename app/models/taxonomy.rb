class Taxonomy < ApplicationRecord

    # has_ancestry
    has_closure_tree order: 'sort_order', 
        dependent: :destroy, 
        numeric_order: true

    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies
    
    validates_presence_of :name, uniqueness: true

    def slug
        name.parameterize
    end

    # default_scope { order(order: :asc).order(name: :asc) }

    scope :categories, -> { where(parent_id: 1) }

end
