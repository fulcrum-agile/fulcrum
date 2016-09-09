class Ownership < ActiveRecord::Base
  belongs_to :team
  belongs_to :project

  def is_owner?
    is_owner
  end
end
