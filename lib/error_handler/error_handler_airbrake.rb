module ErrorHandler
  class AirbrakeErrorHandler
    def notify(*params)
      Airbrake.notify(*params)
    end
  end
end