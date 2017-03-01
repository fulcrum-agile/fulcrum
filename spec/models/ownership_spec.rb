require 'rails_helper'

describe Ownership, type: :model do
  it { is_expected.to belong_to :team }
  it { is_expected.to belong_to :project }
end
