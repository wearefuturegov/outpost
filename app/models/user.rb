class User < ApplicationRecord

  # watch functionality
  has_many :watches
  has_many :services, through: :watches
  has_many :notes

  belongs_to :organisation, optional: true, counter_cache: true

  validates :first_name, presence: true
  validates :last_name, presence: true

  paginates_per 20

  include Discard::Model
  
  include PgSearch::Model
  pg_search_scope :search, 
    against: [:email, :first_name, :last_name], 
    using: {
      tsearch: { prefix: true }
    }

  # sort scopes
  scope :oldest, ->  { order("created_at ASC") }
  scope :newest, ->  { order("created_at DESC") }
  scope :rarely_seen, ->  { order("last_seen ASC NULLS FIRST") }
  scope :latest_seen, ->  { order("last_seen DESC  NULLS LAST") }

  # filter scopes
  scope :admins, ->  { where(admin: true) }
  scope :community, ->  { where("admin is false or admin is null") }
  scope :never_seen, ->  { where(last_seen: nil) }
  scope :only_seen, ->  { where(last_seen: nil) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
          :registerable,
          :recoverable, 
          :rememberable, 
          :lastseenable, 
          :secure_validatable


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
