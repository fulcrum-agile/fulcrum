require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...

  # Check the passed object returns the passed hash from it's as_json
  # method.
  def assert_returns_json(attrs, object)
    wrapper = object.class.name.underscore
    assert_equal(attrs.sort, object.as_json[wrapper].keys.sort)
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
