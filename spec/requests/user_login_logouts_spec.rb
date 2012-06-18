require 'spec_helper'
include Warden::Test::Helpers

describe "UserLoginLogouts" do
  before do
    Warden.test_mode!
  end

  describe "GET users/sign_in" do
    it "sign in a application" do
      user = Factory(:user, :email => "goku@dragonball.com", :password => "gohan-sun")
      visit new_user_session_path
      fill_in "Email", :with => "goku@dragonball.com"
      fill_in "Password", :with => "gohan-sun"
      click_button "Sign in"
      current_path.should == root_path
    end

    it "sign in failed in application because email and password doesn't match" do
      visit new_user_session_path
      click_button "Sign in"
      current_path.should == new_user_session_path
    end
  end

  describe "POST sign_out" do
    it "sign out a user" do
      user = Factory(:user)
      login_as(user, :scope => :user)
      visit users_path
      click_link "Sign out"
      visit users_path
      current_path.should == users_path
      page.should have_content("Sign in")
    end
  end
end
