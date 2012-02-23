module Fulcrum
  module Bushido
    def self.enable_bushido!
      self.load_hooks!
      self.extend_user!
      self.extend_project!
      self.disable_devise_for_bushido_controllers!
    end

    def self.extend_user!
      puts "Extending the User model"
      User.instance_eval do
        validates_presence_of   :ido_id
        validates_uniqueness_of :ido_id

        after_create :add_all_projects!
        before_destroy :remove_all_projects!
      end

      User.class_eval do
        def bushido_extra_attributes(extra_attributes)
          self.name  = "#{extra_attributes['first_name'].to_s} #{extra_attributes['last_name'].to_s}"
          if extra_attributes['first_name'] && extra_attributes['last_name']
            self.initials  = "#{extra_attributes['first_name'][0].upcase}#{extra_attributes['last_name'][0].upcase}"
          else
            self.initials  = "#{extra_attributes['email'][0].upcase}#{extra_attributes['email'][1].upcase}"
          end

          self.email = extra_attributes["email"]
        end

        def add_all_projects!
          Project.all.each { |project| project.users << self unless project.users.member?(self) }
        end

        def remove_all_projects!
          Project.all.each { |project| project.users.delete(self) if project.users.member?(self) }
        end
      end
    end

    def self.extend_project!
      puts "Extending the Project model"
      Project.instance_eval do
        after_create :add_all_users!
      end

      Project.class_eval do
        def add_all_users!
          User.all.each do |user|
            unless self.users.include?(user)
              self.users << user
            end
          end
        end
      end
    end

    def self.load_hooks!
      Dir["#{Dir.pwd}/lib/bushido/**/*.rb"].each { |file| load file }
    end

    # Temporary hack because all routes require authentication in
    # Fulcrum
    def self.disable_devise_for_bushido_controllers!
      puts "Disabling devise auth protection on bushido controllers"

      ::Bushido::DataController.instance_eval { before_filter :authenticate_user!, :except => [:index]  }
      ::Bushido::EnvsController.instance_eval { before_filter :authenticate_user!, :except => [:update] }
      ::Bushido::MailController.instance_eval { before_filter :authenticate_user!, :except => [:index]  }

      puts "Devise checks disabled for Bushido controllers"
    end
  end
end

if Bushido::Platform.on_bushido?
  class BushidoRailtie < Rails::Railtie
    config.to_prepare do
      puts "Enabling Bushido"
      Fulcrum::Bushido.enable_bushido!
      puts "Finished enabling Bushido"
    end
  end
end
