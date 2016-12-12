module FriendlyId
  module Disabler
    THREAD_LOCAL_KEY = :__friendly_id_enabler_disabled

    class << self
      def disabled?
        !!Thread.current[THREAD_LOCAL_KEY]
      end

      def disable_friendly_id(&block)
        begin
          old_value, Thread.current[THREAD_LOCAL_KEY] = Thread.current[THREAD_LOCAL_KEY], true
          block.call
        ensure
          Thread.current[THREAD_LOCAL_KEY] = old_value
        end
      end
    end
  end
end
