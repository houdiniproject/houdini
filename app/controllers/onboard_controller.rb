class OnboardController < ApplicationController
  layout 'layouts/apified'
  include Controllers::XFrame
	after_filter :deny_x_frame_option
  def index
    @theme = 'minimal'
  end
end
