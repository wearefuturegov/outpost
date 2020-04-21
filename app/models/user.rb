class User < ApplicationRecord

  # watch functionality
  has_many :watches
  has_many :services, through: :watches
  has_many :notes

  belongs_to :organisation, optional: true

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:email], 
    using: {
      tsearch: { prefix: true }
    }

    # filter scopes
    scope :admins, ->  { where(admin: true) }
    scope :community, ->  { where("admin is false or admin is null") }

    # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
