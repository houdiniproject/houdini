# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventsController < ApplicationController
	include Controllers::EventHelper

	helper_method :current_event_editor?
  before_filter :authenticate_nonprofit_user!, only: :name_and_id
	before_filter :authenticate_event_editor!, only: [:update, :soft_delete, :stats, :create, :duplicate]


	def index
    @nonprofit = current_nonprofit
	end

  def listings
    render json: QueryEventMetrics.for_listings('nonprofit', current_nonprofit.id, params)
  end

	def show
    @event = params[:event_slug] ? Event.find_by_slug!(params[:event_slug]) : Event.find_by_id!(params[:id])
    @event_background_image = FetchBackgroundImage.with_model(@event)
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
        params[:event][:start_datetime] = Chronic.parse(params[:event][:start_datetime]) if params[:event][:start_datetime].present?
        params[:event][:end_datetime] = Chronic.parse(params[:event][:end_datetime]) if params[:event][:end_datetime].present?
      end
      flash[:notice] = 'Your draft event has been created! Well done.'
      ev = current_nonprofit.events.create(params[:event])
      {url: "/events/#{ev.slug}", event: ev}
    end
	end

	def update
    Time.use_zone(current_nonprofit.timezone || 'UTC') do
      params[:event][:start_datetime] = Chronic.parse(params[:event][:start_datetime]) if params[:event][:start_datetime].present?
      params[:event][:end_datetime] = Chronic.parse(params[:event][:end_datetime]) if params[:event][:end_datetime].present?
    end
		current_event.update_attributes(params[:event])
		json_saved current_event, 'Successfully updated'
	end

  # post 'nonprofits/:np_id/events/:event_id/duplicate'
  def duplicate
    render_json { InsertDuplicate.event(current_event.id, current_user.profile.id)}
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
		@event_background_image = FetchBackgroundImage.with_model(@event)
		render layout: 'layouts/embed'
	end

  def name_and_id
    render json: QueryEvents.name_and_id(current_nonprofit.id)
  end


end
