# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class ButtonController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization

    before_action :authenticate_user!

    def send_code
      NonprofitMailer.button_code(current_nonprofit, params[:to_email], params[:to_name], params[:from_email], params[:message], params[:code]).deliver
      render json: {}, status: 200
    end

    def basic
      @nonprofit = current_nonprofit
    end

    def guided
      @nonprofit = current_nonprofit
    end

    def advanced
      @nonprofit = current_nonprofit
    end
  end
end
