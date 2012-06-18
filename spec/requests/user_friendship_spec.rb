require 'spec_helper'
include Warden::Test::Helpers

describe "UserFriendship" do
  before do
    Warden.test_mode!
  end

  describe "POST create" do
    it "user creates friendship", :js => true do
      user = Factory(:user)
      login_as(user, :scope => :user)
      user2 = Factory(:user)
      visit user_path(user2)
      click_link "Add Friend"
      page.should have_content("Waiting approval")
    end

    it "user accept friendship", :js => true do
      user = Factory(:user)
      user2 = Factory(:user)
      user2.be_friends_with(user)
      login_as(user, :scope => :user)
      visit users_path
      click_link "Accept Friend"
      page.should have_content("Friend")
    end

  end

  describe "DELETE destroy" do
    it "user deny friendship", :js => true do
      user = Factory(:user)
      user2 = Factory(:user)
      user2.be_friends_with(user)
      visit user_path(user)
      click_link "friend-#{user2.id}"
      page.should have_content("Add Friend")
    end
  end
end
