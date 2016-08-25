class Activity < ActiveRecord::Base
  class ChangedValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.action == 'update' && !value.changed?
        record.errors[attribute] << ( options[:message] || "Record didn't change" )
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

  scope :with_dependencies, -> {
    includes(:user)
  }

  scope :projects, ->(ids) {
    where(project_id: ids) if ids
  }
  scope :since, ->(date) {
    where("created_at > ?", date.beginning_of_day) if date
  }

  def self.grouped_activities(allowed_project_ids, since)
    projects(allowed_project_ids).since(since).group_by { |activity|
      activity.created_at.beginning_of_day
    }.
    map { |date, activities|
      [
        date,
        activities.group_by { |activity|
          activity.project_id
        }.
        map { |project_id, activities|
          [
            project_id,
            activities.group_by { |activity|
              activity.subject_destroyed_type || activity.subject_type
            }
          ]
        }
      ]
    }
  end

  def describe
    if action == 'destroy'
      object = "#{subject_destroyed_type} ##{subject_changes['id']}"
    else
      object = case subject_type
        when 'Project'
          "#{subject_type} ##{subject_id} - '#{subject.try(:name)}'"
        when 'Story'
          "#{subject_type} ##{subject_id} - '#{subject.try(:title)}'"
        when 'Note', 'Task'
          "#{subject_type} ##{subject_id} of Story '#{subject.story.title}'"
        end
      if action == 'update'
        changes = subject_changes.keys.reject { |key| %w(updated_at created_at).include?(key) }.map do |key|
          if subject_changes[key].first.nil?
            "#{key} to '#{subject_changes[key].last}' "
          else
            "#{key} from '#{subject_changes[key].first}' to '#{subject_changes[key].last}' "
          end
        end.join(", ")
        object = object + " changed " + changes
      end
    end
    "#{user.name} #{action}d #{object}"
  end

  protected

  def parse_changes
    if action == 'update'
      self.subject_changes = subject.changes
    elsif action == 'destroy'
      self.subject_changes = subject.attributes
      self.subject_destroyed_type = subject.class.name
      self.subject = nil
    end
  end
end
