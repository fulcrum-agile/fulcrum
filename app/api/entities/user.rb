class Entities::User < Entities::BaseEntity
  expose :name
  expose :initials
  expose :email
  expose :sign_in_count
  expose :role

  with_options(format_with: :iso_timestamp) do
    expose :created_at, if: lambda { |i, o| i.created_at.present? }
    expose :confirmed_at, if: lambda { |i, o| i.confirmed_at.present? }
    expose :last_sign_in_at, if: lambda { |i, o| i.last_sign_in_at.present? }
    expose :current_sign_in_at, if: lambda { |i, o| i.current_sign_in_at.present? }
  end
end
