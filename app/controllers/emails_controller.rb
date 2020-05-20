# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailsController < ApplicationController
  before_action :authenticate_user!

  def create
    email = params[:email]
    GenericMailer.generic_mail(email[:from_email], email[:from_name], email[:message], email[:subject], email[:to_email], email[:to_name]).deliver_later
    render json: { notification: 'Email successfully sent' }, status: :created
  end
end
