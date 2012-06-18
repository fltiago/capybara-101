class CreateFriendships < ActiveRecord::Migration
  def up
    create_table :friendships do |t|
      t.references :user, :friend
      t.datetime :requested_at, :accepted_at, :null => true, :default => nil
      t.string :status
    end

    add_index :friendships, :user_id
    add_index :friendships, :friend_id
    add_index :friendships, :status
  end

  def down
    drop_table :friendships
  end
end
