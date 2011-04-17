class EstimateValidator < ActiveModel::EachValidator
  # Checks that the estimate being validated is valid for record.project
  def validate_each(record, attribute, value)
    if record.project
      unless record.project.point_values.include?(value)
        record.errors[attribute] << "is not an allowed value for this project"
      end
    end
  end
end
