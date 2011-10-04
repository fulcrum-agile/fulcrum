class Tagging < ActiveRecord::Base
  belongs_to :story
  belongs_to :tag
  validates_presence_of :story, :tag
end
