class Team < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :enrollments
  has_many :users, through: :enrollments

  has_many :ownerships
  has_many :projects, through: :ownerships do
    def not_archived
      where(archived_at: nil)
    end
  end

  scope :not_archived, -> { where(archived_at: nil) }

  validates :name, presence: true, uniqueness: true

  has_attachment :logo, accept: [:jpg, :png, :gif, :bmp]

  def is_admin?(user)
    enrollments.find_by_user_id(user.id)&.is_admin?
  end

  def allowed_domain?(email)
    whitelist = ( registration_domain_whitelist || "" ).split(/[,;\|\n]/).map(&:strip)
    blacklist = ( registration_domain_blacklist || "" ).split(/[,;\|\n]/).map(&:strip)
    has_whitelist = true
    unless whitelist.empty?
      has_whitelist = whitelist.any? { |domain| email.include?(domain) }
    end
    has_blacklist = false
    unless blacklist.empty?
      has_blacklist = blacklist.any? { |domain| email.include?(domain) }
    end
    has_whitelist && !has_blacklist
  end
end
