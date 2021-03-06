class Taxonomy < ApplicationRecord

    has_closure_tree order: 'sort_order', 
        dependent: :destroy, 
        numeric_order: true

    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies

    attr_accessor :skip_mongo_callbacks
    after_commit :update_index, if: -> { skip_mongo_callbacks == !true }
    after_commit :trigger_scout_rebuild
    
    validates_presence_of :name, uniqueness: true
    validates :name, length: { minimum: 2 }
    validates :name, length: { maximum: 100 }
    
    def slug
        name.parameterize
    end

    def trigger_scout_rebuild
        TriggerScoutRebuildJob.perform_later
    end

    def update_index
        UpdateIndexTaxonomiesJob.perform_later(self)
    end

    def self.options_for_select
      order("LOWER(name)").map { |e| [e.name, e.id] }.unshift(["All taxonomies", ""])
    end
end
