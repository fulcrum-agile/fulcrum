require 'rails_helper'

describe Enrollment, type: :model do
  it { is_expected.to belong_to :team }
  it { is_expected.to belong_to :user }
end
