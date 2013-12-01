FactoryGirl.define do

  factory :user do |u|
    u.sequence(:name) {|n| "User #{n}"}
    u.sequence(:initials) {|n| "U#{n}"}
    u.sequence(:email) {|n| "user#{n}@example.com"}
    u.password 'password'
    u.password_confirmation 'password'
    u.after(:build) {|user| user.confirm!}
  end

  factory :unconfirmed_user, :class => User do |u|
    u.sequence(:name) {|n| "Unconfirmed User #{n}"}
    u.sequence(:initials) {|n| "U#{n}"}
    u.sequence(:email) {|n| "unconfirmed_user#{n}@example.com"}
  end

  factory :project do |p|
    p.name 'Test Project'
  end

  factory :story do |s|
    s.title 'Test story'
    s.association :requested_by, :factory => :user
    s.association :project
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

end
