require 'rails_helper'

describe ImportWorker do

  let(:project)  { create :project }
  let(:importer) { ImportWorker.new }
  let(:import)   { mock_model(Attachinary::File, fullpath: Rack::Test::UploadedFile.new(csv) )}

  before do
    allow(Project).to receive_message_chain(:friendly, :find).with(project.id).and_return(project)
    allow(project).to receive(:import) { import }
    importer.instance_eval do
      def set_cache(key, value)
        @cache ||= {}
        @cache.merge!(key => value)
      end

      def get_cache
        @cache
      end
    end
    I18n.locale = :en
  end

  context 'valid csv' do
    let(:csv)      { 'spec/fixtures/csv/stories.csv' }

    it "must import from CSV and create the proper stories" do
      importer.perform('foo', project.id)
      expect(project.stories.count).to eq(48)
      expect(project.start_date).to eq(Date.parse('2009-11-28'))
      expect(importer.get_cache).to eq("foo" => { invalid_stories: [], errors: nil})
    end
  end

  context 'illegal csv' do
    let(:csv)      { 'spec/fixtures/csv/stories_illegal.csv' }

    it "must import from CSV and create the proper stories" do
      importer.perform('foo', project.id)
      expect(project.stories.count).to eq(0)
      expect(importer.get_cache).to eq("foo" => { invalid_stories: [], errors: "Illegal quoting in line 1."})
    end
  end

  context 'invalid csv' do
    let(:csv)      { 'spec/fixtures/csv/stories_invalid.csv' }

    before { Timecop.freeze(Time.local(2016,9,2,12,0,0)) }
    after { Timecop.return }

    it "must import from CSV and create the proper stories" do
      importer.perform('foo', project.id)
      expect(project.stories.count).to eq(1)
      expect(project.start_date).to eq(Date.parse('2009-11-28'))
      expect(project.stories.first.accepted_at.to_date).to eq(Date.parse("2009-11-28"))
      expect(project.stories.first.created_at.to_date).to eq(Date.parse('2016-09-02'))
      expect(project.stories.first.owned_by_initials).to eq("ML")
      expect(project.stories.first.requested_by_name).to eq("Malcolm Locke")
      expect(project.stories.first.state).to eq("accepted")
      expect(project.stories.first.story_type).to eq("bug")
      expect(project.stories.first.title).to eq("Valid story")
      expect(importer.get_cache).to eq("foo" => {:invalid_stories=>[{:title=>"This story has an invalid estimate and type", :errors=>"Story type is not included in the list, Estimate is not an allowed value for this project, Estimate Bug or Chore stories can't be estimated"}], :errors=>nil})
    end
  end
end
