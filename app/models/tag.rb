class Tag < ActiveRecord::Base
  belongs_to :project
  has_many :taggings, :dependent => :destroy
  has_many :stories, :through => :taggings

  validates_presence_of :name, :project

  def to_s
    name
  end
end
