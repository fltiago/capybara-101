require 'spec_helper'

describe "UserFriendship" do
  self.use_transactional_fixtures = false
  let(:user) { Factory(:user) }
  let(:user2) { Factory(:user) }

  describe "POST create" do
    it "user accept friendship", :js => true do
      user2.be_friends_with(user)
      login_as(user, :scope => :user)
      visit users_path
      click_link "Accept Friend"
      page.should have_content("Friend")
      page.should_not have_content("Accept Friend")
    end

    it "user creates friendship", :js => true do
      login_as(user, :scope => :user)
      visit user_path(user2)
      click_link "Add Friend"
      page.should have_content("Waiting approval")
    end
  end
end
