class User < ActiveRecord::Base
  include Central::Support::UserConcern::Associations
  include Central::Support::UserConcern::Validations
  include Central::Support::UserConcern::Callbacks

  # FIXME - DRY up, repeated in Story model
  JSON_ATTRIBUTES = ["id", "name", "initials", "username", "email"]

  AUTHENTICATION_KEYS = %i[email team_slug]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys:   AUTHENTICATION_KEYS,
         strip_whitespace_keys: AUTHENTICATION_KEYS,
         confirmation_keys:     AUTHENTICATION_KEYS,
         reset_password_keys:   AUTHENTICATION_KEYS
         # unlock_keys: AUTHENTICATION_KEYS

  # Flag used to identify if the user was found or created from find_or_create
  attr_accessor :was_created

  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  def to_s
    "#{name} (#{initials}) <#{email}>"
  end

  # Sets :reset_password_token encrypted by Devise
  # returns the raw token to pass into mailer
  def set_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.current.utc
    self.save(validate: false)
    raw
  end

  def as_json(options = {})
    super(only: JSON_ATTRIBUTES)
  end

  private

  def self.find_first_by_auth_conditions(warden_conditions)
    if warden_conditions[:reset_password_token]
      where(reset_password_token: warden_conditions[:reset_password_token]).first
    elsif warden_conditions[:confirmation_token]
      where(confirmation_token: warden_conditions[:confirmation_token]).first
    else
      user = joins(enrollments: [:team]).where(email: warden_conditions[:email], teams: { slug: warden_conditions[:team_slug] }).first
      if user.nil?
        create_administrator(warden_conditions)
      else
        user
      end
    end
  end

  def self.create_administrator(warden_conditions)
    user = User.find_by_email(warden_conditions[:email])
    team = Team.not_archived.find_by_slug(warden_conditions[:team_slug])
    # if this is a brand new team, without any enrollments yet, the first logged in user becomes administrator
    if user && team && team.enrollments.count.zero?
      team.enrollments.create(user: user, is_admin: true)
      user
    end
  end

end
