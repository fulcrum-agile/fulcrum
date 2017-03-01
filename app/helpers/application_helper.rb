module ApplicationHelper
  def team_logo(image_path)
    cl_image_tag(image_path, { size: '32x32', crop: :fill, radius: 5, border: '1px_solid_black' })
  end
end
