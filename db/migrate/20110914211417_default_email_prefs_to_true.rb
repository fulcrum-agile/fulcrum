class DefaultEmailPrefsToTrue < ActiveRecord::Migration
  def self.up
    User.where('email_delivery IS NULL or email_acceptance IS NULL OR email_rejection IS NULL').each do |u|
      u.update_attributes :email_delivery => true, :email_acceptance => true, :email_rejection => true
    end
  end

  def self.down
  end
end
