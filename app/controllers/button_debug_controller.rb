class ButtonDebugController < ApplicationController
  def embedded
    @np = params[:id] || 1
    respond_to { |format| format.html{render layout: 'layouts/empty'} }
  end

  def button
    @np = params[:id] || 1
    respond_to { |format| format.html{render layout: 'layouts/empty'} }
  end
end
