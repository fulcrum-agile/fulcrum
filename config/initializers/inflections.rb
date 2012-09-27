# encoding: utf-8
# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
   inflect.plural /^(μέλ)ος/ui, '\1η'
   inflect.plural /^(ιστορί)α/ui, '\1ες'
   inflect.uncountable %w( πρότζεκτ )
end
