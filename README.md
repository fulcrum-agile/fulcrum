Fulcrum
=======

Fulcrum is an application to provide a user story based backlog management
system for agile development teams.  See
[the project page](http://wholemeal.co.nz/projects/fulcrum.html) for more
details.

Get involved
------------

Fulcrum is still in early development, so now is the time to make your mark on
the project.

There are several communication channels for Fulcrum:

* [Follow @fulcrumagile on Twitter](https://twitter.com/fulcrumagile)
* [Fulcrum Users](http://groups.google.com/group/fulcrum-users) - A general
  discussion group for users of Fulcrum.
* [Fulcrum Developers](http://groups.google.com/group/fulcrum-devel) - Discussion
  on the development of Fulcrum.
* You might also find someone in #fulcrum on the Freenode IRC network if you're
  looking for realtime help.

See the *Development* section below for details on contributing to the project.

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
[prerequisites for running Ruby on Rails 3.0.x installed](http://rubyonrails.org/download)

Once you have these:

    # Checkout the project
    $ git clone git://github.com/malclocke/fulcrum.git
    $ cd fulcrum
    
    # Install the project dependencies
    $ gem install bundler
    $ bundle install
    
    # Set up the development database
    $ bundle exec rake fulcrum:setup db:setup
    
    # Start the local web server
    $ rails server

You should then be able to navigate to `http://localhost:3000/` in a web browser.
You can log in with the test username `test@example.com`, password `testpass`.


Heroku setup
------------

If you wish to host a publicly available copy of Fulcrum, the easiest option is
to host it on [Heroku](http://heroku.com/).

To deploy it to Heroku, make sure you have a local copy of the project; refer 
to the previous section for instuctions. Then:

    # Make sure you have the Heroku gem
    $ gem install heroku

    # Create your app. Replace APPNAME with whatever you want to name it.
    $ heroku create APPNAME --stack bamboo-mri-1.9.2
   
    # Define where the user emails will be coming from
    # (This email address does not need to exist)
    $ heroku config:add MAILER_SENDER=noreply@example.org

    # Allow emails to be sent
    $ heroku addons:add sendgrid:starter

    # Deploy the first version
    $ git push heroku master

    # Set up the database
    $ heroku rake db:setup

Once that's done, you will be able to view your site at 
`http://APPNAME.heroku.com`.

Development
-----------

Fulcrum is currently welcoming contributions.  If you'd like to help:

* Check the [issue queue](http://github.com/malclocke/fulcrum/issues) for a
  list of the major features which are yet to be implemented.  These have the
  `feature` and `unstarted` labels.  If a feature you'd like isn't there, add
  an issue.
* If you'd like to take ownership of one of the features, leave a comment on
  the issue queue indicating that you're working on it.
* If you'd like to discuss anything about the issue with other developers,
  do so on the [Fulcrum Developers](http://groups.google.com/group/fulcrum-devel)
  mailing list.

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
* Run `rake test` to check the Rails test suite is green.  To run the
  Javascript test suite, run `rake jasmine` and point your browser to
  `http://localhost:8888/`
* For any UI changes, please try to follow the
  [Tango theme guidelines](http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines).


Colophon
--------

Fulcrum is built with the following Open Source technologies:

* [Ruby on Rails](http://rubyonrails.org/)
* [Backbone.js](http://documentcloud.github.com/backbone/)
* [jQuery](http://jquery.com/)
* [Tango Icon Library](http://tango.freedesktop.org/Tango_Icon_Library)
* [Jasmine](http://pivotal.github.com/jasmine/)
* [Sinon](http://sinonjs.org/)

License
-------
Copyright 2011, Malcolm Locke.

Fulcrum is made available under the Affero GPL license version 3, see
LICENSE.txt.
