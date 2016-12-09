require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  it { is_expected.to belong_to(:team) }
end
