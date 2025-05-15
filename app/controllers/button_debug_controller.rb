# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ButtonDebugController < ApplicationController
  def embedded
    @np = params[:id] || 1
    respond_to { |format| format.html { render layout: "layouts/empty" } }
  end

  def button
    @np = params[:id] || 1
    respond_to { |format| format.html { render layout: "layouts/empty" } }
  end
end
