class FlashResponder < ActionController::Responder
  def to_html
    unless get? || has_errors? || options.delete(:flash) == false
      namespace = controller.controller_path.split('/')
      namespace << controller.action_name
      controller.flash[:notice] ||= I18n.t(namespace.join("."), :scope => :flash,
      :default => "actions.#{controller.action_name}".to_sym, :resource => resource.class.model_name.human)
    end
    super
  end

  protected

    def api_behavior(error)
      if put?
        display resource, :status => :ok
      else
        super(error)
      end
    end
end