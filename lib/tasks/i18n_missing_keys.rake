# Fetched from: http://github.com/koppen/i18n_missing_keys.git

namespace :i18n do
  desc "Find and list translation keys that do not exist in all locales"
  task :missing_keys => :environment do
    finder = MissingKeysFinder.new(I18n.backend)
    finder.find_missing_keys
  end
end


class MissingKeysFinder

  def initialize(backend)
    @backend = backend
    self.load_config
    self.load_translations
  end

  # Returns an array with all keys from all locales
  def all_keys
    I18n.backend.send(:translations).collect do |check_locale, translations|
      collect_keys([], translations).sort
    end.flatten.uniq
  end

  def find_missing_keys
    output_available_locales
    output_unique_key_stats(all_keys)

    missing_keys = {}
    all_keys.each do |key|

      I18n.available_locales.each do |locale|

        skip = false
        ls = locale.to_s
        if !@yaml[ls].nil?
          @yaml[ls].each do |re|
            if key.match(re)
              skip = true
              break
            end
          end
        end

        if !key_exists?(key, locale) && skip == false
          if missing_keys[key]
            missing_keys[key] << locale
          else
            missing_keys[key] = [locale]
          end
        end
      end
    end

    output_missing_keys(missing_keys)
    return missing_keys
  end

  def output_available_locales
    puts "#{I18n.available_locales.size} #{I18n.available_locales.size == 1 ? 'locale' : 'locales'} available: #{I18n.available_locales.join(', ')}"
  end

  def output_missing_keys(missing_keys)
    puts "#{missing_keys.size} #{missing_keys.size == 1 ? 'key is missing' : 'keys are missing'} from one or more locales:"
    missing_keys.keys.sort.each do |key|
      puts "'#{key}': Missing from #{missing_keys[key].collect(&:inspect).join(', ')}"
    end
  end

  def output_unique_key_stats(keys)
    number_of_keys = keys.size
    puts "#{number_of_keys} #{number_of_keys == 1 ? 'unique key' : 'unique keys'} found."
  end

  def collect_keys(scope, translations)
    full_keys = []
    translations.to_a.each do |key, translations|
      next if translations.nil?

      new_scope = scope.dup << key
      if translations.is_a?(Hash)
        full_keys += collect_keys(new_scope, translations)
      else
        full_keys << new_scope.join('.')
      end
    end
    return full_keys
  end

  # Returns true if key exists in the given locale
  def key_exists?(key, locale)
    I18n.locale = locale
    I18n.translate(key, :raise => true)
    return true
  rescue I18n::MissingInterpolationArgument
    return true
  rescue I18n::MissingTranslationData
    return false
  end

  def load_translations
    # Make sure we’ve loaded the translations
    I18n.backend.send(:init_translations)
  end

  def load_config
    @yaml = {}
    begin
      @yaml = YAML.load_file(File.join(Rails.root, 'config', 'ignore_missing_keys.yml'))
    rescue => e
      STDERR.puts "No ignore_missing_keys.yml config file."
    end

  end

end
