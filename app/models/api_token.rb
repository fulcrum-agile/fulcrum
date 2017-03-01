class ApiToken < ActiveRecord::Base
  before_create :generate_token

  belongs_to :team

  private

  def generate_token
    self.token = SecureRandom.hex
  end
end
