# http://devcenter.heroku.com/articles/using-compass

require 'compass_twitter_bootstrap'
require 'fileutils'
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))
