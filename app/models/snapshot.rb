class Snapshot < ApplicationRecord
  belongs_to :user
  belongs_to :service

  def restore
    # update object and relevant associations from stored edit
    live_object = Service.find(self.service_id)

    self.object["service_taxonomies"].each do |t|
      live_object.service_taxonomies = []
      live_object.service_taxonomies.upsert(t)
    end

    # byebug

    # self.object["send_needs"].each do |t|
    #   live_object.send_needs = []
    #   live_object.send_needs.new(t)
    # end

    live_object.name = self.object[:name]
    live_object.save
  end

  def preview
    # show a pretty hash for display in version history
  end
end