require 'spec_helper'

describe User do
  describe "POST user" do
    it "creates a user" do
      visit new_user_registration_path
      fill_in "Email", :with => "goku@dragonball.com"
      fill_in "Password", :with => "gohan-sun"
      fill_in "Password confirmation", :with => "gohan-sun"
      click_button "Sign up"
      user = User.find_by_email("goku@dragonball.com")
      current_path.should == root_path
    end

    it "try to create invalid user" do
      visit new_user_registration_path
      fill_in "Email", :with => ""
      fill_in "Password", :with => "goha"
      fill_in "Password confirmation", :with => ""
      click_button "Sign up"
      page.should have_content("Email can't be blank")
      page.should have_content("Password is too short (minimum is 6 characters)")
      page.should have_content("Password doesn't match confirmation")
    end
  end
end

