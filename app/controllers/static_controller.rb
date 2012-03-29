class StaticController < ApplicationController

  class Project
    extend ActiveModel::Naming

    attr_accessor :name

    def to_model
      self
    end

    def valid?()      true end
    def new_record?() true end
    def destroyed?()  true end

    def errors
      obj = Object.new
      def obj.[](key)         []  end
      def obj.full_messages() []  end
      obj
    end
  end

  def testcard
    @project = Project.new
    @project.name = 'Testcard Project'
  end

end
