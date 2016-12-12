require "attachinary/orm/active_record"

module Attachinary
  module FileMixin
    def as_json(options = {})
      super(only: [:id, :public_id, :format, :version, :resource_type], methods: [:path])
    end
  end

  module ViewHelpersExtension
    def attachinary_file_field_options(model, relation, options={})
      options = super(model, relation, options)
      options[:html][:data][:attachinary][:files].map!(&:attributes)
      options
    end
  end

  module ViewHelpers
    prepend ViewHelpersExtension
  end
end
