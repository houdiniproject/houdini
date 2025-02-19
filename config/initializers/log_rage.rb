# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Rails.application.configure do
  if (Rails.env != 'test')


  config.lograge.enabled = true
  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    {   time: event.time,
        exception: event.payload[:exception], # ["ExceptionClass", "the message"]
        exception_object: event.payload[:exception_object] # the exception instance
    }
  end
  end
end