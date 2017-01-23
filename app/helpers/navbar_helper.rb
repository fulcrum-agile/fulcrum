module NavbarHelper
  def active_class(link_path)
    current_page?(link_path) ? "active" : ""
  end

  def settings_active_class(project)
    unless active_class(edit_project_path(project)).empty? &&
           active_class(import_project_path(project)).empty? &&
           active_class(project_integrations_path(project)).empty?
      return "active"
    end
  end
end
