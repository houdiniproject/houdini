# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventDiscountsController < ApplicationController
  include Controllers::EventHelper
	before_action :authenticate_event_editor!, :except => [:index]

  def create
    params[:event_discount][:event_id] = current_event.id

    render JsonResp.new(params[:event_discount]){|data|
      requires(:code, :name).as_string
      requires(:event_id, :percent).as_int
    }.when_valid{|data|
      { status: 200, json: { event_discount: current_event.event_discounts.create(data) } }
    }
  end

  def index
    render json: QueryEventDiscounts.with_event_ids([current_event.id])
  end

  def update
    @event_discount = current_event.event_discounts.find(params[:id])
    
    @event_discount.update!(event_discount_params)
    binding.pry
    @event_discount
  end

  def destroy
    @event_discount = current_event.event_discounts.find(params[:id])

    @event_discount.destroy!

    @event_discount
  end

  private

  def event_discount_params
    params.require(:event_discount).permit(:code, :name, :percent)
  end

end
