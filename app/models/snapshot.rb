class Snapshot < ApplicationRecord
  belongs_to :user
  belongs_to :service

  def restore
    # update object and relevant associations from stored edit
    live_object = Service.find(self.service_id)

    self.object["service_taxonomies"].each do |t|
      new_taxa = ServiceTaxonomy.upsert(t)
    end
    
    live_object.name = self.object[:name]
    live_object.save
  end

  def preview
    # show a pretty hash for display in version history
  end
end