# http://devcenter.heroku.com/articles/using-compass

require 'fileutils'
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))

Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
    :urls => ['/stylesheets'],
    :root => "#{Rails.root}/tmp")
