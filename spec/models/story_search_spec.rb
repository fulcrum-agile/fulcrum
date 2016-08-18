require 'rails_helper'

describe StorySearch do

  let(:project) { FactoryGirl.create :project }
  let(:story) { FactoryGirl.create :story, title: "Simple Story FOO BAR", project: project }

  describe "simple query" do
    let(:query_params) { "FOO" }
    subject { StorySearch.new(project, query_params) }

    it "returns a story" do
      expect(subject.conditions).to eq({})
      expect(subject.parsed_params).to eq(["FOO"])
    end
  end

  describe "complex query" do
    let(:query_params) { "FOO state:unstarted estimate:3" }
    subject { StorySearch.new(project, query_params) }

    it "returns a story" do
      expect(subject.conditions).to eq({'state' => 'unstarted', 'estimate' => '3'})
      expect(subject.parsed_params).to eq(["FOO"])
    end
  end
end
