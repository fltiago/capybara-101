require "spec_helper"
require "ruby-debug"

# unset models used for testing purposes
Object.unset_class('User')

class User < ActiveRecord::Base
  has_friends
end

describe "has_friends" do
  before do
    User.delete_all

    @vader = User.create(:login => "darth_vader")
    @luke = User.create(:login => "luke_skywalker")
    @leia = User.create(:login => "princess_leia")
    @han_solo = User.create(:login => "han_solo")
    @yoda = User.create(:login => "yoda")
  end

  describe "methods" do
    it "should respond to has_friends method" do
      User.should respond_to(:has_friends)
    end

    it "should respond to be_friends_with method" do
      @vader.should respond_to(:be_friends_with)
    end

    it "should respond to friends? method" do
      @vader.should respond_to(:friends?)
    end

    it "should respond to friends_in_common_with method" do
      @vader.should respond_to(:friends_in_common_with)
    end

    it "should responde to friends_not_in_common_with" do
      @vader.should respond_to(:friends_not_in_common_with)
    end

    it "should respond to friends_of_friends method" do
      @vader.should respond_to(:friends_of_friends)
    end

    it "should respond to destroy_friendship_with" do
      @vader.should respond_to(:destroy_friendship_with)

    end
  end

  describe "friends" do
    before(:each) do
      create_friendship @vader, @luke
      create_friendship @vader, @leia
      create_friendship @luke, @leia
      create_friendship @luke, @yoda
      create_friendship @leia, @han_solo
    end

    it "should order vader's friends" do
      # => princess_leia, luke_skywalker
      @vader.friends.all(:order => 'login desc').should == [@leia, @luke]
    end

    it "should return luke's friends" do
      @luke.friends.should == [@vader, @leia, @yoda]
    end

    it "should return leia's frieds" do
      @leia.friends.should == [@vader, @luke, @han_solo]
    end

    it "should return yoda's friends" do
      @yoda.friends.should == [@luke]
    end

    it "should return solo's friends" do
      @han_solo.friends.should == [@leia]
    end

    it "should increment counter" do
      @vader.reload
      @vader.friends_count.should == 2
    end

    it "should decrement counter" do
      friendship = @vader.friendship_for(@luke)
      friendship.destroy

      @vader.reload
      @vader.friends_count.should == 1
    end

    it "should be @vader" do
      @vader.is?(@vader).should be_true
    end

    it "should not be @vader" do
      @vader.is?(@leia).should_not be_true
    end

    it "should return vader and luke friends in common" do
      @vader.friends_in_common_with(@luke).should == [@leia]
    end

    it "should return vader and luke friends not in common" do
      create_friendship @vader, @han_solo
      @vader.friends_not_in_common_with(@luke).should == [@han_solo]
    end

    it "should return friends of vader's friends" do
      @vader.friends_of_friends.should == [@yoda, @han_solo]
    end

    it "should destroy friendship" do
      expect {
        @vader.destroy_friendship_with(@luke)
      }.should change(Friendship, :count).by(-2)
    end
  end

  describe "friendship request" do
    it "should return nil and 'friend is required' status" do
      friendship, status = @vader.be_friends_with(nil)

      friendship.should be_nil
      status.should == Friendship::STATUS_FRIEND_IS_REQUIRED
    end

    it "should return nil and 'is you' status" do
      friendship, status = @vader.be_friends_with(@vader)

      friendship.should be_nil
      status.should == Friendship::STATUS_IS_YOU
    end

    it "should return nil and 'already friends status" do
      @vader.be_friends_with(@luke)
      @luke.be_friends_with(@vader)
      friendship, status = @vader.be_friends_with(@luke)

      friendship.should be_nil
      status.should == Friendship::STATUS_ALREADY_FRIENDS
    end

    it "should return nil and 'already requested' status" do
      @vader.be_friends_with(@luke)
      friendship, status = @vader.be_friends_with(@luke)

      friendship.should be_nil
      status.should == Friendship::STATUS_ALREADY_REQUESTED
    end

    it "should return friendship and 'accepted friendship' status" do
      @vader.be_friends_with(@luke)
      friendship, status = @luke.be_friends_with(@vader)

      friendship.should be_kind_of(Friendship)
      status.should == Friendship::STATUS_FRIENDSHIP_ACCEPTED
      @vader.should be_friends(@luke)
      @luke.should be_friends(@vader)
    end

    it "should create friendships" do
      doing {
        @vader.be_friends_with(@luke)

        @vader.friendships.count.should == 1
        @luke.friendships.count.should == 1
      }.should change(Friendship, :count).by(2)
    end
  end

  describe Friendship do
    it "should be pending status" do
      @friendship = Friendship.new(:status => 'pending')
      @friendship.should be_pending
    end

    it "should be accepted status" do
      @friendship = Friendship.new(:status => 'accepted')
      @friendship.should be_accepted
    end

    it "should be requested status" do
      @friendship = Friendship.new(:status => 'requested')
      @friendship.should be_requested
    end

    context "when attaching has_many" do
      before do
        class Thing < ActiveRecord::Base
          belongs_to :friendship
        end

        class Friendship < ActiveRecord::Base
          has_many :things, :dependent => :destroy
        end
      end

      it "should destroy related" do
        @friendships = create_friendship @vader, @han_solo
        @thing = Thing.create(:friendship => @friendships.first)
        expect {
          @vader.destroy
        }.should change(Thing, :count).by(-1)
      end
    end
  end

  describe "pagination" do
    before(:each) do
      pending unless Object.const_defined?('Paginate')

      create_friendship @vader, @luke
      create_friendship @vader, @leia
      create_friendship @vader, @han_solo
    end

    it "should paginate friends" do
      @vader.friends.paginate(:limit => 1).to_a.should == [@luke, @leia]
    end
  end

  private
    def create_friendship(user1, user2)
      user1.be_friends_with(user2)
      user2.be_friends_with(user1)
    end
end
