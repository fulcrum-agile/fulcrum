class Team < ActiveRecord::Base
  DOMAIN_SEPARATORS_REGEX = /[,;\|\n]/

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
  scope :archived, -> { where.not(archived_at: nil) }

  validates :name, presence: true, uniqueness: true

  has_attachment :logo, accept: [:jpg, :png, :gif, :bmp]

  def is_admin?(user)
    enrollments.find_by_user_id(user.id)&.is_admin?
  end

  def owns?(project)
    ownerships.find_by_project_id(project.id)&.is_owner
  end

  def allowed_domain?(email)
    whitelist = ( registration_domain_whitelist || "" ).split(DOMAIN_SEPARATORS_REGEX).map(&:strip)
    blacklist = ( registration_domain_blacklist || "" ).split(DOMAIN_SEPARATORS_REGEX).map(&:strip)
    has_whitelist = true
    has_whitelist = whitelist.any? { |domain| email.include?(domain) } unless whitelist.empty?
    has_blacklist = false
    has_blacklist = blacklist.any? { |domain| email.include?(domain) } unless blacklist.empty?
    has_whitelist && !has_blacklist
  end
end
