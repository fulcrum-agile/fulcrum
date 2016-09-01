require 'rails_helper'

describe StorySearch do

  let(:project) { create :project }
  let(:story) { create :story, title: "Simple Story FOO BAR", project: project }

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

  describe "real searching" do
    before do
      user = create :user
      project.users << user
      @story1 = create :story, title: 'HELLO', labels: "foo,bar", project: project, requested_by: user
      @story2 = create :story, title: 'WORLD', labels: "foo,bar", project: project, requested_by: user
      @story3 = create :story, title: 'HELL', labels: "abc", project: project, requested_by: user
      @story4 = create :story, title: 'WORD', labels: "abc,def", project: project, requested_by: user
    end

    it "returns the HEL stories" do
      expect(StorySearch.new(project, "HELL").search).to eq([@story1, @story3])
      expect(StorySearch.new(project, "WORD").search).to eq([@story4])
    end

    it "returns the foo labeled stories" do
      expect(StorySearch.new(project, "abc").search_labels).to eq([@story3, @story4])
    end
  end
end
