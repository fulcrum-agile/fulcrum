require 'rails_helper'

describe Membership do
  describe "validations" do
    it "requires project and user" do
      subject.project = nil
      subject.user = nil
      subject.valid?
      expect(subject.errors[:project].size).to eq(1)
      expect(subject.errors[:user].size).to eq(1)
    end
  end
end
