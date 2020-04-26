class Edit < ApplicationRecord
  belongs_to :user
  belongs_to :service

  def restore
    # update object and relevant associations from stored edit
    base_object = Service.find(self.service_id)

    self.object["service_taxonomies"].each do |t|
      new_taxa = ServiceTaxonomy.upsert(t)
    end
    
    base_object.name = self.object[:name]
    base_object.save
  end

  def preview
    # show a pretty hash for display in version history
  end
end