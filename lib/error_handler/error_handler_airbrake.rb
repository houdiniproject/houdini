# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ErrorHandler
  class AirbrakeErrorHandler
    def notify(*params)
      Airbrake.notify(*params)
    end
  end
end