class Note < ApplicationRecord
  belongs_to :service, counter_cache: true
  belongs_to :user, optional: true
  
  validates_presence_of :body, length: { maximum: 200 }
end
