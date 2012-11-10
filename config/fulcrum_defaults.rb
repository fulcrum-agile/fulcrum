Configuration.for('fulcrum') do
  # On Heroku, ensure you `heroku config:add APP_HOST=appname.herokuapp.com`
  app_host ENV['APP_HOST'] || '127.0.0.1:3000'

  # The address which system emails will originate from.
  mailer_sender ENV['MAILER_SENDER'] || 'noreply@example.com'

  # Disable registration pages
  disable_registration ENV['DISABLE_REGISTRATION'] || false
end
