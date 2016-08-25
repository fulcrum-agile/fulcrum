class Activity < ActiveRecord::Base
  class ChangedValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.action == 'update' && !value.changed?
        record.errors[attribute] << ( options[:message] || "Record did'nt change" )
      end
    end
  end

  serialize :subject_changes, Hash

  belongs_to :project
  belongs_to :user
  belongs_to :subject, polymorphic: true

  validates :action, presence: true, inclusion: { in: %w(create update destroy) }
  validates :project, presence: true
  validates :user, presence: true
  validates :subject, presence: true, changed: true

  before_save :parse_changes

  protected

  def parse_changes
    return unless action == 'update'
    self.subject_changes = subject.changes
  end
end
