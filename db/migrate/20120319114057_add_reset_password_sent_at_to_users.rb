class AddResetPasswordSentAtToUsers < ActiveRecord::Migration
  def change
    if !column_exists?(:users, :reset_password_sent_at)
      add_column :users, :reset_password_sent_at, :datetime
    end

  end
end
