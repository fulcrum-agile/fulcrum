require 'rails_helper'

describe Integration do

  subject { FactoryGirl.build :integration }

  describe "#project" do
    it "cannot be nil" do
      subject.project_id = nil
      subject.valid?
      expect(subject.errors[:project].size).to eq(1)
    end

    it "must have a valid project_id" do
      subject.project_id = "invalid"
      subject.valid?
      expect(subject.errors[:project].size).to eq(1)
    end

    it "must have a project" do
      subject.project =  nil
      subject.valid?
      expect(subject.errors[:project].size).to eq(1)
    end
  end

  describe "#kind" do
    it "should have a valid kind" do
      subject.kind = 'foo'
      subject.valid?
      expect(subject.errors[:kind].size).to eq(1)
    end

    it "should have a kind" do
      subject.kind = nil
      subject.valid?
      expect(subject.errors[:kind].size).to eq(2)
    end
  end

  describe "#data" do
    it "should have a valid serializable data field" do
      payload = { channel: 'foo', bot_username: 'bar', private_uri: 'baz' }
      subject.data = payload
      subject.save
      subject.reload

      expect(subject.data['channel']).to eq('foo')
      expect(subject.data['bot_username']).to eq('bar')
      expect(subject.data['private_uri']).to eq('baz')
    end
  end
end
