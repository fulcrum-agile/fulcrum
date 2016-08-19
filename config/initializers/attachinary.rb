require "attachinary/orm/active_record"

module Attachinary
  module FileMixin
    def as_json(options = {})
      super(only: [:id, :public_id, :format, :version, :resource_type], methods: [:path])
    end
  end
end
