class ServiceTaxonomy < ApplicationRecord
    belongs_to :service
    belongs_to :taxonomy
end