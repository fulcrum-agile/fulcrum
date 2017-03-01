module SidebarController
  extend ActiveSupport::Concern

  included do
    def set_sidebar(sidebar)
      @sidebar = sidebar
    end

    def sidebar
      return @sidebar
    end
  end
end
