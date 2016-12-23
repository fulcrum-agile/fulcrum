class Entities::Team < Entities::BaseEntity
  expose :slug
  expose :name
  expose :logo
  expose :disable_registration

  with_options(format_with: :iso_timestamp) do
    expose :created_at, if: lambda { |i, o| i.created_at.present? }
    expose :archived_at, if: lambda { |i, o| i.archived_at.present? }
  end
end
