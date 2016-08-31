require 'rails_helper'

describe ActivityPresenter do
  let(:story) { create(:story, :with_project) }
  let(:note) { create(:note, story: story) }
  let(:activity) { build(:activity, project: story.project, user: story.requested_by) }
  let(:user_name) { story.requested_by.name }
  let(:project) { story.project }

  subject { ActivityPresenter.new(activity) }

  context 'destroyed' do
    before { activity.action = 'destroy' }

    it 'describes story destroyed' do
      activity.subject = story
      activity.save
      expect(subject.description).to eq("#{user_name} destroyed Story ##{story.id}")
    end

    it 'describes project destroyed' do
      activity.subject = project
      activity.save
      expect(subject.description).to eq("#{user_name} destroyed Project ##{project.id}")
    end

    it 'describes note destroyed' do
      activity.subject = note
      activity.save
      expect(subject.description).to eq("#{user_name} destroyed Note ##{note.id}")
    end
  end

  context 'created' do
    before { activity.action = 'create' }

    it 'describes story created' do
      activity.subject = story
      activity.save
      expect(subject.description).to eq("#{user_name} created Story ##{story.id} - '<a href=\"/projects/#{project.id}#story-#{story.id}\">Test story</a>'")
    end

    it 'describes project created' do
      activity.subject = project
      activity.save
      expect(subject.description).to eq("#{user_name} created Project '<a href=\"/projects/test-project\">Test Project</a>'")
    end

    it 'describes note created' do
      activity.subject = note
      activity.save
      expect(subject.description).to eq("#{user_name} created Note 'Test note' for Story '<a href=\"/projects/#{project.id}#story-#{story.id}\">Test story</a>'")
    end
  end

  context 'updated' do
    before { activity.action = 'update' }

    context 'from empty values' do
      it 'describes new values in story' do
        story.estimate = 2
        story.description = 'new description'
        activity.subject = story
        activity.save
        expect(subject.description).to eq("#{user_name} updated Story ##{story.id} - '<a href=\"/projects/#{project.id}#story-#{story.id}\">Test story</a>' changing estimate to '2', description to 'new description'")
      end

      it 'describes new values in project' do
        project.start_date = nil
        project.save

        project.start_date = Date.parse('2016-08-30').in_time_zone
        activity.subject = project
        activity.save
        expect(subject.description).to eq("#{user_name} updated Project '<a href=\"/projects/test-project\">Test Project</a>' changing start_date to '2016-08-30'")
      end

      it 'describes new values in note' do
        note.note = nil
        note.save

        note.note = 'new note'
        activity.subject = note
        activity.save
        expect(subject.description).to eq("#{user_name} updated Note 'new note' for Story '<a href=\"/projects/#{project.id}#story-#{story.id}\">Test story</a>' changing note from 'Test note' to 'new note'")
      end
    end

    context 'changing values for new ones' do
      it 'describes changes in story' do
        story.estimate = 2
        story.description = 'old description'
        story.state = 'unstarted'
        story.save

        story.estimate = 4
        story.description = 'new description'
        story.state = 'started'
        activity.subject = story
        activity.save
        expect(subject.description).to eq("#{user_name} updated Story ##{story.id} - '<a href=\"/projects/#{project.id}#story-#{story.id}\">Test story</a>' changing estimate from '2' to '4', description from 'old description' to 'new description', state from 'unstarted' to 'started'")
      end

      it 'describes changes in project' do
        project.start_date = Date.parse('2016-07-01').in_time_zone
        project.save

        project.name = 'New Project'
        project.start_date = Date.parse('2016-08-30').in_time_zone
        activity.subject = project
        activity.save
        expect(subject.description).to eq("#{user_name} updated Project '<a href=\"/projects/test-project\">New Project</a>' changing name from 'Test Project' to 'New Project', start_date from '2016-07-01' to '2016-08-30'")
      end

      it 'describes changes in note' do
        note.note = 'new note'
        activity.subject = note
        activity.save
        expect(subject.description).to eq("#{user_name} updated Note 'new note' for Story '<a href=\"/projects/#{project.id}#story-#{story.id}\">Test story</a>' changing note from 'Test note' to 'new note'")
      end

      it 'describes changing attachments in story' do
        documents_changes = {documents_attributes: [ ['old_file1.jpg', 'old_file2.jpg'], ['old_file2.jpg', 'new_file3.jpg'] ]}
        expect(story).to receive(:changes).and_return(documents_changes)
        expect(story).to receive(:changed?).and_return(true)
        activity.subject = story
        activity.save
        expect(subject.description).to eq("#{user_name} updated Story ##{story.id} - '<a href=\"/projects/#{project.id}#story-#{story.id}\">Test story</a>' changing documents by uploading 'new_file3.jpg' and by deleting 'old_file1.jpg'")
      end
    end
  end
end
