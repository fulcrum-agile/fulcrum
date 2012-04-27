require 'spec_helper'

describe User do

  describe "validations" do
    
    it "requires a name" do
      subject.name = ''
      subject.should have(1).error_on(:name)
    end

    it "requires initials" do
      subject.initials = ''
      subject.should have(1).error_on(:initials)
    end

  end

  describe "#to_s" do

    subject { Factory.build(:user, :name => "Dummy User", :initials => "DU",
                                    :email => "dummy@example.com") }

    its(:to_s) { should == "Dummy User (DU) <dummy@example.com>" }

  end

  describe "#as_json" do

    before do
      subject.id = 42
    end

    specify {
      subject.as_json['user'].keys.sort.should == %w[email id initials name]
    }

  end

  describe "reset_password_sent_at default" do
    subject do
      user = Factory.build(:unconfirmed_user)
      user.valid?
      user
    end

    its(:reset_password_sent_at) { should_not be_nil }
  end

end
