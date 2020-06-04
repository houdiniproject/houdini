# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventsController < ApplicationController
  include Controllers::Event::Current
  include Controllers::Event::Authorization

  helper_method :current_event_editor?
  before_action :authenticate_nonprofit_user!, only: :name_and_id
  before_action :authenticate_event_editor!, only: %i[update soft_delete stats create duplicate]

  def index
    @nonprofit = current_nonprofit
  end

  def listings
    render json: QueryEventMetrics.for_listings('nonprofit', current_nonprofit.id, params)
  end

  def show
    @event = params[:event_slug] ? Event.find_by_slug!(params[:event_slug]) : Event.find_by_id!(params[:id])
    @event_background_image = @event.background_image.attached? && url_for(@event.background_image_by_size(:normal))
    @nonprofit = @event.nonprofit
    if @event.deleted && !current_event_editor?
      redirect_to nonprofit_path(current_nonprofit)
      flash[:notice] = "Sorry, we couldn't find that event"
      return
    end
    @organizer = QueryEventOrganizer.with_event(@event.id)
  end

  def create
    render_json do
      Time.use_zone(current_nonprofit.timezone || 'UTC') do
        event_params[:start_datetime] = Chronic.parse(event_params[:start_datetime]) if event_params[:start_datetime].present?
        event_params[:end_datetime] = Chronic.parse(event_params[:end_datetime]) if event_params[:end_datetime].present?
      end
      flash[:notice] = 'Your draft event has been created! Well done.'
      ev = current_nonprofit.events.create(event_params)
      { url: "/events/#{ev.slug}", event: ev }
    end
  end

  def update
    Time.use_zone(current_nonprofit.timezone || 'UTC') do
      event_params[:start_datetime] = Chronic.parse(event_params[:start_datetime]) if event_params[:start_datetime].present?
      event_params[:end_datetime] = Chronic.parse(event_params[:end_datetime]) if event_params[:end_datetime].present?
    end
    current_event.update(event_params)
    json_saved current_event, 'Successfully updated'
  end

  # post 'nonprofits/:np_id/events/:event_id/duplicate'
  def duplicate
    render_json { InsertDuplicate.event(current_event.id, current_user.profile.id) }
  end

  def activities
    render json: QueryTickets.for_event_activities(params[:id])
  end

  def soft_delete
    current_event.update_attribute(:deleted, params[:delete])
    render json: {}
   end

  def metrics
    render json: QueryEventMetrics.with_event_ids([current_event.id]).first
  end

  def stats
    @event = current_event
    @url = Format::Url.concat(root_url, @event.url)
    @event_background_image = @event.background_image.attached? && url_for(@event.background_image_by_size(:normal))
    render layout: 'layouts/embed'
  end

  def name_and_id
    render json: QueryEvents.name_and_id(current_nonprofit.id)
  end

  private

  def event_params
    params.require(:event).permit(:deleted, :name, :tagline, :summary, :body, :end_datetime, :start_datetime, :latitude, :longitude, :location, :city, :state_code, :address, :zip_code, :main_image, :remove_main_image, :background_image, :remove_background_image, :published, :slug, :directions, :venue_name, :profile_id, :ticket_levels_attributes, :show_total_raised, :show_total_count, :hide_activity_feed, :nonprofit_id, :hide_title, :organizer_email, :receipt_message)
  end
end
