require_relative '../../app/helpers/session'

include SessionHelpers

feature 'User should be able to reset their password if they have forgotten it' do 
  
  scenario 'when a password reset is requested a randomised token is created in the user record' do
    reset_password
    expect(User.first.password_token).not_to be(nil)
  end

  scenario 'password token directs user to successfully change password' do
    reset_password
    token = User.first.password_token
    visit "/users/reset_password/#{token}"
    fill_in :email, with: 'alice@example.com' 
    fill_in :new_password, with: 'banana'
    fill_in :new_password_confirmation, with: 'banana'
    click_button "Reset password"
    expect(page).to have_content("Your password has been successfully changed")
  end

end