# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventDiscountsController < ApplicationController
  include Controllers::EventHelper
  before_action :authenticate_event_editor!, except: [:index]

  def create
    params[:event_discount][:event_id] = current_event.id

    render JsonResp.new(params[:event_discount]) do |_data|
      requires(:code, :name).as_string
      requires(:event_id, :percent).as_int
    end.when_valid do |data|
      { status: 200, json: { event_discount: current_event.event_discounts.create(data) } }
    end
  end

  def index
    render json: QueryEventDiscounts.with_event_ids([current_event.id])
  end

  def update
    discount = Hamster.to_ruby(
      Psql.execute(
        Qexpr.new.update(:event_discounts, params[:event_discount])
        .where('id=$id', id: params[:id])
        .returning('*')
      ).first
    )
    render json: { status: 200, data: discount }
  end

  def destroy
    Psql.execute(
      Qexpr.new.delete_from('event_discounts')
        .where('event_discounts.event_id=$id', id: params['event_id'])
        .where('event_discounts.id=$id', id: params['id'])
    )
  end
end
