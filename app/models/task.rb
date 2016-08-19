class Task < ActiveRecord::Base
  belongs_to :story

  validates :name, presence: true
end
