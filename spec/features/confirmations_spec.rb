require 'rails_helper'

describe "Confirmations" do

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  it "sends a confirmation token" do
    visit '/'
    first(:link, 'Sign up').click
    # Sign the user up for an account
    fill_in 'Name', :with => 'Test User'
    fill_in 'Initials', :with => 'TU'
    fill_in 'Username', :with => 'testuser'
    fill_in 'Email', :with => 'test@example.com'
    click_button 'Sign up'

    expect(page).to have_content('A confirmation was sent to your e-mail')

    # The user will be sent a confirmation email.  Bypass that and just pull
    # their confirmation token from the database.

    email = ActionMailer::Base.deliveries.last
    expect(email.to).to include('test@example.com')
    confirmation_token = get_confirmation_token_from_mail(email)

    user = User.find_by_email('test@example.com')
    visit '/users/confirmation?confirmation_token=' + confirmation_token
    expect(page).to have_content('Your account was successfully confirmed')

    # User should at this point be prompted to set a password
    fill_in 'New password', :with => 'password'
    fill_in 'Confirm new password', :with => 'password'
    click_on 'Change my password'

    expect(current_path).to eq(root_path)
    expect(page).to have_content('Your password was changed successfully')
  end

  it "gracefully handles an invalid confirmation token" do
    visit '/users/confirmation?confirmation_token=foo'
    expect(page).to have_content('Invalid confirmation token')
  end

  it "sends new confirmation token" do
    user = FactoryGirl.create(:unconfirmed_user, :email => 'test@example.com')
    visit '/'
    click_link "Didn't receive confirmation instructions?"

    fill_in 'Email', :with => user.email
    click_button 'Resend confirmation instructions'

    expect(page).to have_content('You will receive an email with instructions about how to confirm your account in a few minutes')

    # There should be 2 deliveries, one from the user creation and one from
    # the resend instructions form.
    expect(ActionMailer::Base.deliveries.length).to eq(2)
  end

end
