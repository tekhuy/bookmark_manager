require_relative '../../app/helpers/session'

include SessionHelpers

feature 'User should be able to reset their password if they have forgotten it' do 
  
  scenario 'when a password reset is requested a randomised token is created in the user record' do
    sign_up
    visit '/users/forgot_password'
    fill_in :email, with: 'alice@example.com'
    click_button "Reset password"
    expect(User.first.password_token).not_to be(nil)
  end

end