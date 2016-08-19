if Rails.env.production?
  Devise::Async.backend = :sidekiq
  Devise::Async.enabled = true
end
