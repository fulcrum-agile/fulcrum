require 'feature_helper'

describe "Logins" do

  let!(:user)  {
    create :user, :with_team_and_is_admin,
                  email: 'user@example.com',
                  password: 'password',
                  name: 'Test User',
                  locale: 'en',
                  time_zone: 'Brasilia'
  }

  describe "disable registration" do
    before do
      Configuration.for('fulcrum') do
        disable_registration true
      end
    end

    after do
      Configuration.for('fulcrum') do
        disable_registration false
      end
    end

    it "removes the sign up link" do
      visit root_path
      expect(page).to have_selector('h1', text: 'Log In')

      expect(page).not_to have_selector('a', text: 'Sign up')
    end
  end

  describe "successful login" do
    it "logs in the user", js: true do
      visit root_path
      fill_in "Email",    with: 'user@example.com'
      fill_in "Password", with: 'password'
      click_button 'Sign in'

      expect(page).to have_selector('h1', text: I18n.t('teams.switch'))
      expect(page).to have_selector('.user-dropdown', text: 'Test User')
    end


    describe '2 Factor Auth' do
      context "when account wasn't enabled yet" do
        before { user.update authy_enabled: true }

        it 'redirects to enable authy page', js: true do
          visit root_path
          expect(page).to have_selector('h1', text: 'Log In')

          fill_in "Email",     with: "user@example.com"
          fill_in "Password",  with: "password"
          click_button 'Sign in'
          expect(page).to have_selector('h2', text: I18n.t('authy_register_title', scope: 'devise'))
        end
      end

      context "when account was already enabled" do
        before { user.update authy_enabled: true, authy_id: '12345', last_sign_in_with_authy: Time.current }

        it 'redirects to verify token page', js: true do
          visit root_path
          expect(page).to have_selector('h1', text: 'Log In')

          fill_in "Email",     with: "user@example.com"
          fill_in "Password",  with: "password"
          click_button 'Sign in'

          expect(page).to have_selector('legend', text: I18n.t('submit_token_title', scope: 'devise'))
        end
      end
    end
  end

  describe "successful logout", js: true do
    before do
      sign_in user
    end

    it "logs out the user" do
      visit root_path
      find('.user-dropdown').trigger 'click'
      click_on 'Log out'

      expect(page).to have_selector('h1', text: 'Log In')
    end
  end
end
