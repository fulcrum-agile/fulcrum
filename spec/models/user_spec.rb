require 'spec_helper'

describe User do

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:initials) }
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

end
