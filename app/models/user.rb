class User < ApplicationRecord

  # watch functionality
  has_many :watches, dependent: :destroy
  has_many :services, through: :watches
  has_many :notes
  has_many :service_versions, foreign_key: :whodunnit

  belongs_to :organisation, optional: true, counter_cache: true
  
  attr_accessor :skip_name_validation
  validates :first_name, presence: true, unless: :skip_name_validation
  validates :last_name, presence: true, unless: :skip_name_validation

  acts_as_taggable_on :labels
  
  paginates_per 20

  include Discard::Model
  
  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :email, :first_name, :last_name], 
    using: {
      trigram: {
        threshold: 0.1
      }
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

  scope :in_directory, -> (directory) { joins(organisation: :services).merge(Service.in_directory(directory)).distinct if directory.present? }

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
    ActsAsTaggableOn::Tag.distinct.order(:name).map { |t| [t.name, t.name] }.unshift(["All labels", ""])
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

  def can_edit_taxonomies
    admin_users?
  end

  def can_edit_custom_fields
    admin_users?
  end
end
