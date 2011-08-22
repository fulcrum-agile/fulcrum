Fulcrum
=======

Fulcrum is an application to provide a user story based backlog management
system for agile development teams.  See
[the project page](http://wholemeal.co.nz/projects/fulcrum.html) for more
details.

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
    $ rake db:setup
    $ rake db:seed
    
    # Start the local web server
    $ rails server

You should then be able to navigate to `http://localhost:3000/` in a web browser.
You can log in with the test username `test@example.com`, password `testpass`.

If you wish to host a publicly available copy of Fulcrum, the easiest option is
to host it on [Heroku](http://heroku.com/).  You'll find full instructions on
setting up Rails applications on their website.

Development
-----------

Fulcrum is currently welcoming contributions, but if you're planning on
implementing a major feature please contact us first, your feature may
already be in progress.

The following features are being developed actively at the moment:

* Iterations
* Comments

Particularly welcome at the time of writing would be UI improvement and
clean ups.

For any development, please bear the following in mind:

* Please send patches as either github pull requests or as git patches.
  Try to break patches up into the smallest logical blocks possible.  We'd
  prefer to receive many small commits to one large one.
* All patches should be covered by tests, and should not break the existing
  tests, unless a current test is invalidated by a code change.  This includes
  Javascript, which is covered with a Jasmine test
  suite in `spec/javascripts/`.
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
