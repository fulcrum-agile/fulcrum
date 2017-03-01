class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :authy_authenticatable, :database_authenticatable, :trackable, :validatable

  validates :email, presence: true
end
