class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :story

  attr_accessible :note

  after_save :create_changeset

  validates :note, :presence => true

  def create_changeset
    story.changesets.create! if story
  end

  # Defines the attributes and methods that are included when calling to_json
  def as_json(options = {})
    super(:methods => ["errors"])
  end
end
