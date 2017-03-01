class Entities::Team < Entities::BaseEntity
  expose :slug
  expose :name
  expose :logo
  expose :disable_registration
  expose :admins, if: { type: :full }

  with_options(format_with: :iso_timestamp) do
    expose :created_at, if: lambda { |i, o| i.created_at.present? }
    expose :archived_at, if: lambda { |i, o| i.archived_at.present? }
  end

  private

  def admins
    object.enrollments.includes(:user).where(is_admin: true).map(&:user) rescue []
  end
end
