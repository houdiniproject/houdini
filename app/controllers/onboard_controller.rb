class OnboardController < ApplicationController
  layout 'layouts/apified'
  include Controllers::XFrame
	after_filter :add_x_frame_options
  def index
    @theme = 'minimal'
  end
end
