class User < ApplicationRecord

  # watch functionality
  has_many :watches
  has_many :services, through: :watches
  has_many :notes

  belongs_to :organisation, optional: true

  validates :first_name, presence: true
  validates :last_name, presence: true

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:email, :first_name, :last_name], 
    using: {
      tsearch: { prefix: true }
    }

  # filter scopes
  scope :admins, ->  { where(admin: true) }
  scope :community, ->  { where("admin is false or admin is null") }
  scope :never_seen, ->  { where(last_seen: nil) }
  scope :only_seen, ->  { where(last_seen: nil) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lastseenable

  def display_name
    if first_name && last_name
      [first_name, last_name].join(' ')
    else
      email
    end
  end
end
