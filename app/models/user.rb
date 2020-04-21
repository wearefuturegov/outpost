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

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
