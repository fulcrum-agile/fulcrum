module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tags, :through => :taggings, :dependent => :destroy
    has_many :taggings
    attr_writer :tag_string
    after_save :parse_tags
  end

  module InstanceMethods
    def tag_string
      @tag_string || self.tags.join(",")
    end

    private
      def parse_tags
        labels = self.tag_string.split(",")
        labels.reject!(&:blank?)
        labels.map!(&:strip)
        labels.uniq!
        self.tags = labels.map do |label|
          Tag.find_or_create_by_name_and_project_id( :name => label, :project_id => self.project_id )
        end
      end
  end
end