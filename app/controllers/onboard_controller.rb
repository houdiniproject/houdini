class OnboardController < ApplicationController
  layout "layouts/apified"
  def index
    @theme = "minimal"
  end
end
