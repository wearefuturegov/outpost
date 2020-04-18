class User < ApplicationRecord

  # watch functionality
  has_many :watches
  has_many :services, through: :watches

  belongs_to :organisation, optional: true

  acts_as_approval_user

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
