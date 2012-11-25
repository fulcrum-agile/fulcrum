module IntegrationHelpers

  def sign_in(user, password = 'password')
    visit root_path
    fill_in "user_email",    :with => user.email
    fill_in "user_password", :with => password
    click_button 'Sign in'
  end

end
