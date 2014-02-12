class Task < ActiveRecord::Base
  belongs_to :story
  
  validates :task, :presence => true
end
