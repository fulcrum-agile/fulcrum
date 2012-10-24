module IntegrationHelpers

  def sign_in(user, password = 'password')
    visit root_path
    fill_in "Email",    :with => user.email
    fill_in "Password", :with => password
    click_button 'Sign in'
  end
  
  def send_keys keys, options = {}
    element = options[:element] ? options.delete(:element) : find('html')
    element.native.send_keys keys
  end
end
