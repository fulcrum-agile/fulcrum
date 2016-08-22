class Task < ActiveRecord::Base
  belongs_to :story

  validates :name, presence: true

  before_destroy { |record| raise ActiveRecord::ReadOnlyRecord if record.readonly? }

  def readonly?
    story.readonly?
  end
end
