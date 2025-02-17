# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
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
