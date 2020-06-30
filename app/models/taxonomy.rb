class Taxonomy < ApplicationRecord

    has_closure_tree order: 'sort_order', 
        dependent: :destroy, 
        numeric_order: true

    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies

    attr_accessor :skip_mongo_callbacks
    after_save :update_index, unless: :skip_mongo_callbacks
    
    validates_presence_of :name, uniqueness: true

    scope :categories, -> { where(parent_id: 1) }

    def update_index
        UpdateIndexTaxonomiesJob.perform_later(self)
    end
end
