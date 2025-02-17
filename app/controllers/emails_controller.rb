# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class EmailsController < ApplicationController
  before_action :authenticate_user!

  def create
    email = params[:email]
    GenericMailer.generic_mail(email[:from_email], email[:from_name], email[:message], email[:subject], email[:to_email], email[:to_name]).deliver_later
    render json: {notification: "Email successfully sent"}, status: :created
  end
end
