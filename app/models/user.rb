class User < ApplicationRecord

  # watch functionality
  has_many :watches
  has_many :services, through: :watches
  has_many :notes

  belongs_to :organisation, optional: true, counter_cache: true

  validates :first_name, presence: true
  validates :last_name, presence: true

  acts_as_taggable_on :labels
  
  paginates_per 20

  include Discard::Model
  
  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :email, :first_name, :last_name], 
    using: {
      tsearch: { prefix: true }
    }

  filterrific(
    default_filter_params: { sorted_by: "created_at_desc"},
    available_filters: [
      :sorted_by,
      :search,
      :roles,
      :tagged_with
    ],
  )

  scope :roles, ->(value) { 
    case value.to_s
    when "community"
      where("admin is false or admin is null")
    when "admin"
      where(admin: true)
    end
  }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^created_at_/
      order("created_at #{direction}  NULLS LAST")
    when /^last_seen_/
      order("last_seen #{direction}  NULLS LAST")
    end
  }

  def self.options_for_sorted_by
    [
      ["Joined recently", "created_at_desc"],
      ["Joined earliest", "created_at_asc"],
      ["Last seen", "last_seen_desc"],
      ["Rarely seen", "last_seen_asc"]
    ]
  end

  def self.options_for_roles
    [
      ["All roles", "false"],
      ["Only community users", "community"],
      ["Only admins", "admin"]
    ]
  end

  def self.options_for_labels
    ActsAsTaggableOn::Tag.most_used.map { |t| [t.name, t.name] }.unshift(["All labels", ""])
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
          :registerable,
          :recoverable, 
          :rememberable, 
          :lastseenable, 
          :secure_validatable

  has_many :access_grants,
          class_name: 'Doorkeeper::AccessGrant',
          foreign_key: :resource_owner_id,
          dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
          class_name: 'Doorkeeper::AccessToken',
          foreign_key: :resource_owner_id,
          dependent: :delete_all # or :destroy if you need callbacks

  def active_for_authentication? 
    super && kept? 
  end 
        
  def display_name
    if first_name && last_name
      [first_name, last_name].join(' ')
    else
      email
    end
  end

  def initials
    if first_name && last_name
      [first_name[0,1], last_name[0,1]].join('').upcase
    else
      email[0,1].upcase
    end
  end
end
