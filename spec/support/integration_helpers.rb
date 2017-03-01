module IntegrationHelpers

  def sign_in(user, password = 'password')
    visit root_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: password
    click_button 'Sign in'
    find(:css, '.card-link', match: :first).click
  end

  def send_keys keys, options = {}
    keycode = case keys
      when '?'
        63
      when 'B'
        66
      when 'C'
        67
      when 'D'
        68
      when 'P'
        80
      when 'a'
        97
      when :pause
        19
      else
        keys
    end
    element = options[:element] ? options.delete(:element) : 'body'
    keypress_script = "var e = jQuery.Event('keypress', { keyCode: #{keycode} }); jQuery('#{element}').trigger(e);"
    page.execute_script(keypress_script)
  end

  # FIXME this is a bit brittle but the Devise now stores encrypted tokens
  # and sends a raw one so this grabs it from the email body so will have to
  # do for now.
  def get_confirmation_token_from_mail(email)
    content = Nokogiri::HTML(email.body.encoded)
    token = content.at('a')['href'].split('confirmation_token=').last
    token
  end

  def wait_spinner
    expect(page).not_to have_css('.loading-spin.show')
  end

  def wait_page_load
    find('.column_header', match: :first).click
  end
end
