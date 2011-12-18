require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  setup do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test "it should redirect to user sign in after registartion" do
    post :create, :user => {:name => 'Test User', :initials => 'TU', :email => 'test_user@example.com'}
    assert_equal 'You have signed up successfully. A confirmation was sent to your e-mail. Please follow the contained instructions to activate your account.',
      flash[:notice]
    assert_redirected_to(new_user_session_path)
  end
end
