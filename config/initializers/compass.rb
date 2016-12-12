# http://devcenter.heroku.com/articles/using-compass

require 'fileutils'
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))

# Workaround Compass bug
module Compass::SassExtensions::Functions::Sprites
  def sprite_path(map)
    Sass::Script::String.new(map.filename)
  end
  Sass::Script::Functions.declare :sprite_path, [:map]
end
