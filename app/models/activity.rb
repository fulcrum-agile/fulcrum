class Activity < ActiveRecord::Base
  include Central::Support::ActivityConcern::Associations
  include Central::Support::ActivityConcern::Validations
  include Central::Support::ActivityConcern::Callbacks
  include Central::Support::ActivityConcern::Scopes

  def decorate
    ActivityPresenter.new(self)
  end
end
