module FlashHelper
  CLASSES_MAP = {
    alert:  'alert-warning',
    notice: 'alert-info',
    error:  'alert-danger'
  }.freeze

  def flash_key_to_bootstrap_class(key)
    CLASSES_MAP[key.to_sym]
  end
end
