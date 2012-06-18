class UsersController < ApplicationController
  def index
    @users = User.find(:all)
  end

  def show
    @user = User.find(params[:id])
    @friendship = current_user.friendship_for(@user)
  end

  def home
  end
end
