Fulcrum
=======

Fulcrum is an application to provide a user story based backlog management
system for agile development teams.  See
[the project page](http://wholemeal.co.nz/projects/fulcrum.html) for more
details.

[![Build Status](https://travis-ci.org/Codeminer42/cm42-central.svg?branch=master)](https://travis-ci.org/Codeminer42/cm42-central)



![Fulcrum Screenshot](https://raw.githubusercontent.com/Codeminer42/cm42-central/master/doc/screenshot.png)


The Codeminer 42 Fork Feature Set
---------------------------------

- [x] Fixing Pivotal Tracker project CSV import to properly get the Notes
- [x] Added stories search through Pg_Search (low priority: maybe add option for Elastic)
- [x] Adding superadmin role to manage projects and users
  - [x] proper users CRUD section
  - [ ] Reorganize the user administration
- [x] Adding Cloudinary/Attachinary support to upload assets to Stories and Notes
  - [ ] Uploading is working but it is not showing properly yet
  - [ ] Add uploads to Notes
- [x] General project cleanup
  - [x] upgrading gems
  - [x] using rails-assets
  - [x] refactoring views to use Bootstrap elements
  - [x] fixing failing migrations
  - [x] fixing failing tests, including javascript tests
  - [x] adding phantomjs for feature tests
  - [ ] remove StoryObserver
  - [ ] (low priority) replace the polling system for a websockets channel and listener
  - [ ] more markdown javascript to assets
  - [ ] (low priority) the initial project loads all stories (up to the STORIES_CEILING), need to asynchronously load the past
  - [ ] needs more testing and tweaking for tablets
  - [ ] Backbone code needs more refactoring and cleanup
- [x] Improved UI
  - [x] A little bit better icon set
  - [x] Textarea in Story editing can now auto-resize
  - [x] Can collapse sprint groups
  - [x] Bugs and Chores shouldn't be estimated
  - [x] Basic task system inside a Story
  - [x] Labels work as "Epic" grouping
  - [ ] (bug) dragging a task to the begging of a sprint is not saving the new priority
  - [ ] (bug) raising error when trying to change state of story from 'started' to 'unstarted'


Get involved
------------

Fulcrum is still in early development, so now is the time to make your mark on
the project.

There are several communication channels for Fulcrum:

* [Follow @fulcrumagile on Twitter](https://twitter.com/fulcrumagile)
* [Fulcrum Users](http://groups.google.com/group/fulcrum-users) - A
  discussion group for users and developers of Fulcrum.
* You might also find someone in #fulcrum on the Freenode IRC network if you're
  looking for realtime help.

See the [Development](#development) section below for details on contributing
to the project, and [Translating](#translating) for details on how to help
translate Fulcrum into your native language.

Goals
-----

Fulcrum is a clone of [Pivotal Tracker](http://pivotaltracker.com/).  It will
almost certainly never surpass the functionality, usability and sheer
awesomeness of Pivotal Tracker, but aims to provide a usable alternative for
users who require a Free and Open Source solution.

Installation
------------

Fulcrum is still a work in progress, but if you're really keen to try it out
these instructions will hopefully help you get up and running.

First up, your system will need the
[prerequisites for running Ruby on Rails installed](http://rubyonrails.org/download)

Once you have these:

    # Checkout the project
    $ git clone git://github.com/fulcrum-agile/fulcrum.git
    $ cd fulcrum

    # copy and edit the configuration
    $ cp .env.sample .env

    # Install the project dependencies
    $ gem install bundler
    $ bundle install

    # Set up the development database
    $ bundle exec rake fulcrum:setup db:setup

    # Start the local web server
    $ bundle exec foreman start -f Procfile.development

Or using docker:

    # Checkout the project
    $ git clone git://github.com/fulcrum-agile/fulcrum.git
    $ cd fulcrum

    # Prepare container
    $ docker-compose build
    $ docker-compose run rake db:create
    $ docker-compose run rake db:migrate
    $ docker-compose run rake db:seeds

    # Up container
    $ docker-compose up

You should then be able to navigate to `http://localhost:3000/` in a web browser.
You can log in with the test username `test@example.com`, password `testpass`.


Heroku setup
------------

If you wish to host a publicly available copy of Fulcrum, the easiest option is
to host it on [Heroku](http://heroku.com/).

To deploy it to Heroku, make sure you have a local copy of the project; refer
to the previous section for instructions. Then:

    $ gem install heroku

    # Define secret tokens
    $ heroku config:set SECRET_TOKEN=`rake secret` SECRET_KEY_BASE=`rake secret`

    # Create your app. Replace APPNAME with whatever you want to name it.
    $ heroku create APPNAME --stack cedar-14

    # Set APP_HOST heroku config so outbound emails have a proper host
    # Replace APPNAME below with the value from `heroku create`
    $ heroku config:set APP_HOST=APPNAME.herokuapp.com

    # Define where the user emails will be coming from
    # (This email address does not need to exist)
    $ heroku config:set MAILER_SENDER=noreply@example.org

    # Tell Heroku to exclude parts of the Gemfile
    $ heroku config:set BUNDLE_WITHOUT='development:test:travis:mysql:sqlite'

    # How many stories a project will load at once (so very old, done stories, stay out of the first load), (optional, default is 300)
    $ heroku config:set STORIES_CEILING=300

    # CDN URL - Go to AWS and create a CloudFront configuration (optional)
    $ heroku config:set CDN_URL=http://xpto.cloudfront.net

    # Font Asset - domain of your app
    $ heroku config:set FONT_ASSET=http://APPNAME.herokuapp.com

    # Add memcache to speed things up (optional)
    $ heroku addons:add memcachier:dev

    # Allow emails to be sent
    $ heroku addons:add sendgrid:starter

    # Deploy the first version
    $ git push heroku master

    # Set up the database
    $ heroku run rake db:setup

Once that's done, you will be able to view your site at
`http://APPNAME.herokuapp.com`.

The recommendation is to create a proper domain and add the herokuapp URL as the CNAME.

Deploying to other platforms
----------------------------

Fulcrum can be deployed to any platform that can host Rails.  Setting this
up is beyond the scope of this document, but for the most part Fulcrum does
not have any special operational requirements and can be deployed as a normal
Rails application.

You will need to set up some custom configuration, to do this copy the file
`config/fulcrum.example.rb` to `config/fulcrum.rb` and edit to your
requirements, or ensure the relevant environment variables are set for the
application as described in the file above.

Translating
-----------

Below is an example of how you might go about translating Fulcrum to German.

* Find the name of your locale, in this case we are using `de`
* Copy the `config/locales/en.yml` file to `config/locales/de.yml`
* Edit the file and update all the translated strings in quotes on the right
  hand side.
* Add your new locale to `config.i18n.available_locales` in
  `config/application.rb`
* Run `rake i18n:js:export` to build the Javascript translations.

Thats it!  Ideally you should send your translation as a pull request so you
get credit for it, but if you do not wish to do this please send the file to
one of the mailing lists.

If Fulcrum has already been translated for your language, please take the time
to check the translation database is complete for your language.  You can do
this by running the `rake i18n:missing_keys` task.  If you find any missing
keys for your language please add them.

Development
-----------

Fulcrum is currently welcoming contributions.  If you'd like to help:

* Check the [issue queue](http://github.com/fulcrum-agile/fulcrum/issues) for a
  list of the major features which are yet to be implemented.  These have the
  `feature` and `unstarted` labels.  If a feature you'd like to work on isn't
  there, add an issue.
* Leave a description of how you are going to implement the feature.  Failure
  to do this may lead to you implementing the feature in a way that might
  conflict with future plans for Fulcrum, and so increase the chances of your
  work being rejected or needing a rework.
* If you'd like to discuss anything about the issue in greater detail with
  other developers, do so on the
  [Fulcrum Developers](http://groups.google.com/group/fulcrum-devel) mailing
  list.

Here are some general guidelines for contributing:

* Make your changes on a branch, and use that branch as the base for pull
  requests.
* Try to break changes up into the smallest logical blocks possible.  We'd
  prefer to receive many small commits to one large one in a pull request.
* Feel free to open unfinished pull requests if you'd like to discuss work
  in progress, or would like other developers to test it.
* All patches changes be covered by tests, and should not break the existing
  tests, unless a current test is invalidated by a code change.  This includes
  Javascript, which is covered with a Jasmine test suite in `spec/javascripts/`.
* Run `rake spec` to check the Rails test suite is green. You will need
  Firefox with Selenium installed to run the integration tests.
* To run the Javascript test suite, run `rails server` and point your browser
  to `http://localhost:3000/specs` or run `rake spec:javascripts`
* For any UI changes, please try to follow the
  [Tango theme guidelines](http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines).
* The easiest way to test the impact of CSS or view changes is using the
  'testcard' at `http://localhost:3000/testcard`.  This is a fake project which
  exposes as many of the view states as possible on one page.


Colophon
--------

Fulcrum is built with the following Open Source technologies:

* [Ruby on Rails](http://rubyonrails.org/)
* [Backbone.js](http://documentcloud.github.com/backbone/)
* [jQuery](http://jquery.com/)
* [Tango Icon Library](http://tango.freedesktop.org/Tango_Icon_Library)
* [Jasmine](http://jasmine.github.io/)
* [Sinon](http://sinonjs.org/)

License
-------
Copyright 2011-2015, Malcolm Locke.

Fulcrum is made available under the Affero GPL license version 3, see
LICENSE.txt.
