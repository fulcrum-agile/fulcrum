class Team < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :enrollments
  has_many :users, through: :enrollments

  has_many :ownerships
  has_many :projects, through: :ownerships do
    def not_archived
      where(is_archived: nil)
    end
  end

  validates :name, presence: true, uniqueness: true

  has_attachment :logo, accept: [:jpg, :png, :gif, :bmp]
end
