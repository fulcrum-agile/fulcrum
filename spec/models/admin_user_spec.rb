require 'rails_helper'

describe AdminUser, type: :model do
  it { is_expected.to validate_presence_of :email }
end
