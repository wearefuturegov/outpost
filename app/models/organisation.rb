class Organisation < ApplicationRecord
  has_many :services
  has_many :users

  attr_accessor :skip_mongo_callbacks
  after_save :update_index, unless: :skip_mongo_callbacks

  paginates_per 20

  filterrific(
    default_filter_params: { sorted_by: "created_at_desc"},
    available_filters: [
      :sorted_by,
      :search_query,
      :users,
      :services
    ],
  )

  scope :users, ->(value) { 
    case value.to_s
    when "with"
      joins(:users)
    when "without"
      left_joins(:users).where(users: {id: nil})
    end
  }
  
  scope :services, ->(value) { 
    case value.to_s
    when "with"
      joins(:services)
    when "without"
      left_joins(:services).where(services: {id: nil})
    end
  }

  scope :search_query, ->(search_query) { 
    search(search_query) 
  }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^created_at_/
      order("created_at #{direction}")
    when /^name_/
      order("LOWER(organisations.name) #{direction} NULLS LAST")
    end
  }

  def self.options_for_sorted_by
    [
      ["Newest first", "created_at_desc"],
      ["Oldest first", "created_at_asc"],
      ["Z-A", "name_desc"],
      ["A-Z", "name_asc"],
    ]
  end

  def self.options_for_users
    [
      ["All", "false"],
      ["Only with users", "with"],
      ["Only without users", "without"]
    ]
  end

  def self.options_for_services
    [
      ["All", "false"],
      ["Only with services", "with"],
      ["Only without services", "without"]
    ]
  end

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :name, :description], 
    using: {
      tsearch: { prefix: true }
    }

  validates_uniqueness_of :name

  def display_name
    if self.name.present?
      name
    else
      "Unnamed organisation #{self.id}"
    end
  end

  def update_index
    UpdateIndexOrganisationsJob.perform_later(self)
  end
end