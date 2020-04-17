class User < ApplicationRecord

  # watch functionality
  has_many :watches
  has_many :services, through: :watches

  has_and_belongs_to_many :users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
