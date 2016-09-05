class Enrollment < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  def is_admin?
    is_admin
  end
end
