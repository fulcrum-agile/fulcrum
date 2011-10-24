class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :story

  after_save :create_changeset

  def create_changeset
    story.changesets.create! if story
  end
end
