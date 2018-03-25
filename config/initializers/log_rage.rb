Commitchange::Application.configure do
  config.lograge.enabled = true
  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    {   time: event.time,
        exception: event.payload[:exception], # ["ExceptionClass", "the message"]
        exception_object: event.payload[:exception_object] # the exception instance
    }
  end
end