# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module DeviseHelper
  # print out all of the first devise error message
  def devise_error_messages!
    if resource&.invalid?
      resource.errors.first.full_message
    end
  end
end
