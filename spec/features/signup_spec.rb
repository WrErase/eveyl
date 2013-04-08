require 'spec_helper'

describe "the signup process", :type => :feature do
  let(:user) { User.create(email: 'user@example.com', password: 'caplin') }

  it "allows me to sign in" do
    visit '/users/sign_up'

    fill_in 'Email', with: 'user2@example.com'
    fill_in 'user_password', with: 'password'
    fill_in 'Password confirmation', with: 'password'

    click_button 'Sign up'

    page.has_content?('You have signed up successfully').should be_true

    User.where(email: 'user2@example.com').should_not be_nil
    User.where(email: 'user2@example.com').first.admin.should be_false
  end

  it "signs me in" do

    visit '/users/sign_in'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    click_button 'Sign in'

    page.has_content?('Signed in successfully.').should be_true
  end
end
