class Integration < ActiveRecord::Base
  VALID_INTEGRATIONS = ['mattermost']

  belongs_to :project
  validates :project, presence: true
  validates :kind, inclusion: { in: VALID_INTEGRATIONS }, presence: true
  validates :data, presence: true
end
