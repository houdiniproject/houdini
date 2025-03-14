# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class EventDiscountsController < ApplicationController
  include Controllers::Event::Current
  include Controllers::Event::Authorization
  before_action :authenticate_event_editor!, except: [:index]

  def create
    render json: {data: {event_discount: current_event.event_discounts.create(event_discount_params[:event_discount])}}
  end

  def index
    render json: QueryEventDiscounts.with_event_ids([current_event.id])
  end

  def update
    current_event_discount.update event_discount_params[:event_discount]
    render json: {status: 200, data: current_event_discount}
  end

  def destroy
    current_event_discount.destroy
  end

  private

  def current_event_discount
    current_event.event_discounts.find(params[:id])
  end

  def event_discount_params
    params.required(:event_discount).permit(:code, :name, :percent)
  end
end
