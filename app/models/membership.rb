class Membership < ActiveRecord::Base
  belongs_to :project, counter_cache: true
  belongs_to :user, counter_cache: true

  validates :project, presence: true
  validates :user, presence: true
end
