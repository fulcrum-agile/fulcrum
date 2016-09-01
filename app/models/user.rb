class User < ActiveRecord::Base

  # FIXME - DRY up, repeated in Story model
  JSON_ATTRIBUTES = ["id", "name", "initials", "username", "email"]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Flag used to identify if the user was found or created from find_or_create
  attr_accessor :was_created

  has_many :memberships, dependent: :destroy
  has_many :projects, -> { uniq }, through: :memberships

  before_validation :set_random_password_if_blank

  before_destroy :remove_story_association

  validates :name, :username, :initials, presence: true
  validates :username, uniqueness: true

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

  def set_random_password_if_blank
    if new_record? && self.password.blank? && self.password_confirmation.blank?
      self.password = self.password_confirmation = Digest::SHA1.hexdigest("--#{Time.current.to_s}--#{email}--")[0,8]
    end
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

  def admin?
    is_admin
  end

  private

  def remove_story_association
    Story.where(requested_by_id: id).update_all(requested_by_id: nil, requested_by_name: nil)
    Story.where(owned_by_id: id).update_all(owned_by_id: nil, owned_by_name: nil)
    Membership.where(user_id: id).delete_all
  end
end
