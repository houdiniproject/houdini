# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class ChargesController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!, only: :index

    # get /nonprofit/:nonprofit_id/charges
    def index
      redirect_to controller: :payments, action: :index
    end # def index
  end
end
