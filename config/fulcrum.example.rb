Configuration.for('fulcrum') do
  # Set this to the domain name of your installation.  Env var APP_HOST
  #app_host 'example.com'

  # The email address that notification emails will be sent from.  Env var
  # MAILER_SENDER
  #mailer_sender 'noreply@example.com'

  # Disable registration pages.  If set to true, users will need to be invited
  # to a project rather than being able to self sign-up.
  # Env var DISABLE_REGISTRATION
  #disable_registration false

  # Project column order:
  # progress_to_right: chilly bin, backlog, in progress, done
  # progress_to_left: done, in progress, backlog, chilly bin
  #column_order 'progress_to_left'
end
