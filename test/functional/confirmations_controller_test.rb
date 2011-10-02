require 'test_helper'

class ConfirmationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  test "should be able to change password after confirmation" do
    user = Factory.create(:user, :reset_password_token => 'fdsedf4343334ik3hhudfug')
    user.confirmed_at = nil
    user.confirmation_token = Devise.friendly_token
    user.confirmation_sent_at = Time.now.utc
    user.save(:validate => false)
    get :show, :confirmation_token => user.confirmation_token
    assert_redirected_to(edit_user_password_path(:reset_password_token => user.reset_password_token))
  end
  test "should not fail with invalid tokens" do
    get :show, :confirmation_token => 'randomtoken'
    assert_equal flash[:notice], 'Invalid confirmation token.'
    assert_redirected_to(new_user_confirmation_path)
  end
  test "should be render new form when resending confirmation instructions" do
    get :new
    assert @response.body.include?("Email")
  end
end
