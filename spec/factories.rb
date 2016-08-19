FactoryGirl.define do

  factory :user do |u|
    u.is_admin { true }
    u.sequence(:name) {|n| "User #{n}"}
    u.sequence(:username) {|n| "username #{n}"}
    u.sequence(:initials) {|n| "U#{n}"}
    u.sequence(:email) {|n| "user#{n}@example.com"}
    u.password 'password'
    u.password_confirmation 'password'
    u.after(:build) {|user| user.confirm }
  end

  factory :unconfirmed_user, :class => User do |u|
    u.sequence(:name) {|n| "Unconfirmed User #{n}"}
    u.sequence(:username) {|n| "testuser#{n}"}
    u.sequence(:initials) {|n| "U#{n}"}
    u.sequence(:email) {|n| "unconfirmed_user#{n}@example.com"}
  end

  factory :project do |p|
    p.name 'Test Project'
    p.start_date { Time.current }
  end

  factory :story do |s|
    s.title 'Test story'
    s.association :requested_by, factory: :user

    trait :with_project do
      after(:build) { |object| object.project = FactoryGirl.create(:project, users: [object.requested_by]) }
    end
  end

  factory :changeset do |c|
    c.association :story
    c.association :project
  end

  factory :note do |n|
    n.note        'Test note'
    n.association :story
    n.association :user
  end

  factory :membership do |m|
    m.association :project
    m.association :user
  end

  factory :task do |t|
    t.name 'Test task'
    t.association :story
  end

  factory :integration do |i|
    i.association :project
    i.kind 'mattermost'
    i.data ( { channel: 'test-channel', bot_username: 'marvin', private_uri: 'http://foo.com' } )
  end
end
