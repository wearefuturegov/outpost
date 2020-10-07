class Snapshot < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :service

  paginates_per 20

  def publicly_visible?
    object['visible'] && object['discarded_at'].nil?
  end
end