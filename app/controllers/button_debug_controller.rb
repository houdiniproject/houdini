# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
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
