class Service < ApplicationRecord
  belongs_to :organisation
  has_one :contact
  has_many :service_at_locations
  has_many :locations, through: :service_at_locations

  # watch functionality
  has_many :watches
  has_many :users, through: :watches

  paginates_per 20
  validates_presence_of :name

  def short_url
    self.url
      .delete_prefix("https://")
      .delete_prefix("http://")
      .delete_prefix("www.")
      .delete_suffix("/")
      .truncate(25)
  end
end