class NotFoundUserNamesForStoryAndNotes < ActiveRecord::Migration
  def change
    add_column :stories, :requested_by_name, :string
    add_column :stories, :owned_by_name, :string
    add_column :stories, :owned_by_initials, :string
    add_column :notes, :user_name, :string

    Story.find_each do |s|
      s.requested_by_name = s.requested_by.try(:name)
      s.owned_by_name = s.owned_by.try(:name)
      s.owned_by_initials = s.owned_by_name.split(' ').map { |n| n[0].upcase }.join('') unless s.owned_by_name.blank?
      s.save
    end

    Note.find_each do |n|
      next if n.story.nil?
      n.user_name = n.user.try(:name)
      n.save
    end
  end
end
