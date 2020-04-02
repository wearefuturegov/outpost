class Service < ApplicationRecord
  belongs_to :organisation

  validates_presence_of :name
  has_one :contact


  def short_url
    self.url
      .delete_prefix("https://")
      .delete_prefix("http://")
      .delete_prefix("www.")
      .delete_suffix("/")
      .truncate(25)
  end
end