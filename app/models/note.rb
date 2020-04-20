class Note < ApplicationRecord
  belongs_to :service
  belongs_to :user
  
  validates_presence_of :body, length: { maximum: 200 }
end
