class FriendshipsController < ApplicationController
  def create
    @friend = User.find(params[:friend_id])
    @create_friend = params[:create_friend]
    current_user.be_friends_with(@friend)

    respond_to do |format|
      format.js
    end
  end

  def destroy
  end
end
