require 'timecop'
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
    reset_url = "/users/reset_password/#{token}"
    visit reset_url
    fill_in_new_password_fields
    expect(page).to have_content("Your password has been successfully changed")
  end

  scenario 'user atempts to use token more than an hour since it was created' do
    reset_password
    Timecop.travel((60*60)+1) # advance time by 1 hour and 1 second
    token = User.first.password_token
    reset_url = "/users/reset_password/#{token}"
    visit reset_url
    expect(page).to have_content("Sorry that token has expired, please request a new one")
  end

  scenario 'user attempts to create new password with wrong email' do
    reset_password
    token = User.first.password_token
    reset_url = "/users/reset_password/#{token}"
    visit reset_url
    fill_in_new_password_fields('wrong@mail.com')
    expect(page).to have_content("You have used an incorrect email address")
  end

end