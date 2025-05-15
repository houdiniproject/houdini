# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventDiscountsController < ApplicationController
  include Controllers::EventHelper
  before_action :authenticate_event_editor!, except: [:index]

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def create
    @event_discount = current_event.event_discounts.build(event_discount_params)

    @event_discount.save!

    render status: :created
  end

  def index
    render json: QueryEventDiscounts.with_event_ids([current_event.id])
  end

  def update
    @event_discount = current_event.event_discounts.find(params[:id])

    @event_discount.update!(event_discount_params)
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

  def record_invalid(error)
    render status: :unprocessable_entity, json: {errors: error.record.errors}
  end
end
