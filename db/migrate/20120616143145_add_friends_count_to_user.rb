class AddFriendsCountToUser < ActiveRecord::Migration
  def up
    add_column :users, :friends_count, :integer, :default => 0, :null => false
  end

  def down
    remove_column :users, :friends_count
  end
end
