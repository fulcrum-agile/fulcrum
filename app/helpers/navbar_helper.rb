module NavbarHelper
  def active_class(link_path)
    current_page?(link_path) ? "active" : ""
  end

  def settings_active_class
    'active' if controller.sidebar == :project_settings
  end
end
