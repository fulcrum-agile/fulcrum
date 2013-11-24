class Changeset < ActiveRecord::Base
  belongs_to :project
  belongs_to :story

  validates :project, :presence => true
  validates :story, :presence => true

  before_validation :assign_project_from_story

  default_scope { order(:id) }

  scope :since, lambda {|id| where("id > ?", id)}
  scope :until, lambda {|id| where('id <= ?', id)}

  protected

  # If project_id is not already set, it can be inferred from the stories
  # project_id
  def assign_project_from_story
    if project_id.nil? && !story_id.nil?
      self.project_id = story.project_id
    end
  end
end
