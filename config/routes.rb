# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  require_relative "state_code_constraint"
  if Rails.env.development?
    get "/button_debug/embedded" => "button_debug#embedded"
    get "/button_debug/button" => "button_debug#button"
    get "/button_debug/embedded/:id" => "button_debug#embedded"
    get "/button_debug/button/:id" => "button_debug#button"
  end

  defaults format: :json do # they're APIs, you have to use JSON
    namespace :api do
      resources :nonprofits, only: [:create, :show] do
        resources(:roles, only: [:index])
        resources :campaigns, only: [:show] do
          resources :campaign_gift_options, only: [:index, :show]
        end
        resources :custom_field_definitions, only: [:index, :show]
        resources :events, only: [:show] do
          resources :ticket_levels, only: [:index, :show]
        end
        resources :supporters, only: [:index, :show] do
          resources :supporter_addresses, only: [:index, :show]
          resources :supporter_notes, only: [:index, :show]
        end
        resources :tag_definitions, only: [:index, :show]
        resources :transactions, only: [:index, :show] do
          resource :subtransaction, only: [:show] do
            resources :payments, only: [:index, :show]
          end
        end
      end

      resources :users, only: [] do
        get :current, on: :collection
      end
    end
  end

  resources(:emails, only: [:create])
  resources(:settings, only: [:index])
  resources(:campaign_gifts, only: [:create])
  resource(:cards, only: %i[create update destroy])
  resource(:direct_debit_details, path: "sepa", controller: :direct_debit_details, only: [:create])

  # Creating presigned posts for direct-to-S3 upload
  resources(:aws_presigned_posts, only: [:create])

  resources(:image_attachments, only: [:create]) do
    post(:remove, on: :collection)
  end

  resources(:profiles, only: %i[show update]) do
    get(:fundraisers, on: :member)
    get(:events, on: :member)
    get(:donations_history, on: :member)
  end

  namespace(:nonprofits, path: "nonprofits/:nonprofit_id") do
    resources(:payouts, only: %i[create index show])
    resources(:imports, only: [:create])
    resources(:nonprofit_keys, only: [:index]) do
      get(:mailchimp_login, on: :collection)
      get(:mailchimp_landing, on: :collection)
    end
    resources(:reports, only: []) do
      get(:end_of_year, on: :collection)
      get(:end_of_year_custom, on: :collection)
    end
    resources(:email_lists, only: %i[index create])
    resources(:payments, only: %i[index show update destroy]) do
      post(:export, on: :collection)
      post(:resend_donor_receipt, on: :member)
      post(:resend_admin_receipt, on: :member)
    end
    resources(:donations, only: %i[index show create update]) do
      put(:followup, on: :member)
      post(:create_offsite, on: :collection)
    end

    resources(:charges, only: [:index]) do
      resources(:refunds, only: %i[create index])
    end

    resource(:bank_account, only: [:create]) do
      get(:confirmation)
      post(:confirm)
      get(:cancellation)
      post(:cancel)
      post(:resend_confirmation)
    end

    resources(:custom_field_definitions, only: %i[index create destroy])
    resources(:custom_field_joins, only: []) do
      post(:modify, on: :collection)
    end

    resources(:tag_definitions, only: %i[index create destroy])
    resources(:tag_joins, only: []) do
      post(:modify, on: :collection)
    end

    resources(:supporters, only: %i[index show create update new]) do
      resources(:tag_joins, only: %i[index destroy])
      resources(:custom_field_joins, only: %i[index destroy])
      resources(:supporter_notes, only: %i[create update destroy])
      resources(:activities, only: [:index])
      post(:export, on: :collection)
      put :bulk_delete, on: :collection
      post :merge, on: :collection
      get :merge_data, on: :collection
      get :info_card, on: :member
      get :email_address, on: :member
      get :full_contact, on: :member
      get :index_metrics, on: :collection
    end

    resources(:recurring_donations, only: %i[index show destroy update create]) do
      post(:export, on: :collection)
    end

    resource(:miscellaneous_np_info, only: %i[show update])

    namespace(:button) do
      root(action: :advanced)
      get(:basic)
      get(:guided)
      get(:advanced)
      post(:send_code)
    end

    post "tracking", controller: "trackings", action: "create"
  end

  namespace(:campaigns, path: "/nonprofits/:nonprofit_id/campaigns/:campaign_id/admin", only: []) do
    resources(:supporters, only: [:index])
    resources(:donations, only: [:index])
    resources(:campaign_gift_options, only: [:index])
  end

  resources(:nonprofits, only: %i[show update destroy]) do
    get(:profile_todos, on: :member)
    get(:recurring_donation_stats, on: :member)
    get(:search, on: :collection)
    get(:dashboard_todos, on: :member)
    put(:verify_identity, on: :member)

    resources(:roles, only: %i[create destroy])
    resources(:settings, only: [:index])
    resources(:pricing, only: [:index])
    resources(:email_settings, only: %i[index create])
    resources(:users, only: %i[index create]) do
      resources(:email_settings, only: %i[index create])
    end

    resources(:campaigns, only: %i[index show create update]) do
      get(:metrics, on: :member)
      get(:totals, on: :member)
      get(:timeline, on: :member)
      post(:duplicate, on: :member)
      get(:activities, on: :member)
      put(:soft_delete, on: :member)
      get(:name_and_id, on: :collection)
      post :create_from_template, on: :collection
      resources(:campaign_gift_options, only: %i[index show create update destroy]) do
        put(:update_order, on: :collection)
      end
    end

    resources(:events, only: %i[index show create update]) do
      get(:metrics, on: :member)
      get(:listings, on: :collection)
      get(:stats, on: :member)
      get(:name_and_id, on: :collection, defaults: {format: :json})
      get(:activities, on: :member)
      post(:duplicate, on: :member)
      put(:soft_delete)
      resources(:tickets, only: %i[create update index destroy]) do
        put(:add_note, on: :member)
        post(:delete_card_for_ticket, on: :member)
      end
      resources(:ticket_levels, only: %i[index show create update destroy]) do
        put(:update_order, on: :collection)
      end
      resources(:event_discounts, only: %i[create index update destroy])
    end

    get(:donate, on: :member)
    get(:btn, on: :member)
    get(:supporter_form, on: :member)
    post(:custom_supporter, on: :member)
    get(:dashboard, on: :member)
    get(:dashboard_metrics, on: :member)
    get(:payment_history, on: :member)

    post(:donate, on: :member, as: "create_donation")
  end

  resources(:recurring_donations, only: %i[edit destroy update]) do
    put(:update_amount, on: :member)
  end

  devise_for :users,
    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      confirmations: "users/confirmations"
    }
  devise_scope :user do
    match "/sign_in" => "users/sessions#new", :via => %i[get post]
    match "/signup" => "devise/registrations#new", :via => %i[get post]
    post "/confirm" => "users/confirmations#confirm", :via => [:get]
    match "/users/is_confirmed" => "users/confirmations#is_confirmed", :via => %i[get post]
    get "/users/exists" => "users/confirmations#exists"
    post "/users/confirm_auth", action: :confirm_auth, controller: "users/sessions", via: %i[get post]
  end

  # Super admin
  match "/admin" => "super_admins#index", :as => "admin", :via => %i[get post]
  match "/admin/search-nonprofits" => "super_admins#search_nonprofits", :via => %i[get post]
  match "/admin/search-profiles" => "super_admins#search_profiles", :via => %i[get post]
  match "/admin/search-fullcontact" => "super_admins#search_fullcontact", :via => %i[get post]
  match "/admin/recurring-donations-without-cards" => "super_admins#recurring_donations_without_cards", :via => %i[get post]
  match "/admin/export_supporters_with_rds" => "super_admins#export_supporters_with_rds", :via => %i[get post]
  match "/admin/resend_user_confirmation" => "super_admins#resend_user_confirmation", :via => %i[get post]

  # GoodJob dashboard
  authenticate :user, ->(user) { user.super_admin? } do
    mount GoodJob::Engine => "good_job"
  end

  # Events
  get "/events" => "events#index"
  match "/events/:event_slug" => "events#show", :via => %i[get post]

  # Campaigns
  match "/peer-to-peer" => "campaigns#peer_to_peer", :via => %i[get post]

  scope ":state_code/:city/:name" do
    constraints StateCodeConstraint.new do
      # Nonprofits
      match "" => "nonprofits#show", :as => :nonprofit_location, :via => %i[get post]
      match "donate" => "nonprofits#donate", :as => :nonprofit_donation, :via => %i[get post]
      match "button" => "nonprofits/button#guided", :via => %i[get post]

      # Campaigns
      match "campaigns" => "campaigns#index", :via => %i[get post]
      match "campaigns/:campaign_slug" => "campaigns#show", :via => %i[get post], :as => :campaign_location
      match "campaigns/:campaign_slug/supporters" => "campaigns/supporters#index", :via => %i[get post]

      # Events
      match "events" => "events#index", :via => %i[get post]
      match "events/:event_slug" => "events#show", :via => %i[get post], :as => :event_location
      match "events/:event_slug/stats" => "events#stats", :via => %i[get post]
      match "events/:event_slug/tickets" => "tickets#index", :via => %i[get post]

      # Dashboard
      match "dashboard" => "nonprofits#dashboard", :as => :np_dashboard, :via => %i[get post]
    end
  end

  direct :campaign_locateable do |model, options|
    nonprofit = model.nonprofit
    route_for(:campaign_location, nonprofit.state_code_slug, nonprofit.city_slug, nonprofit.slug,
      model.slug, options)
  end

  direct :event_locateable do |model, options|
    nonprofit = model.nonprofit
    route_for(:event_location, nonprofit.state_code_slug, nonprofit.city_slug,
      nonprofit.slug, model.slug, options)
  end

  # Mailchimp Landing
  match "/mailchimp-landing" => "nonprofits/nonprofit_keys#mailchimp_landing", :via => %i[get post]

  # Webhooks
  post "/webhooks/stripe_subscription_payment" => "webhooks#subscription_payment"
  post "/webhooks/stripe" => "webhooks#stripe"

  get "/static/terms_and_privacy" => "static#terms_and_privacy"
  get "/static/ccs" => "static#ccs"

  get "/js/donate-button.v2.js" => "widget#v2"
  get "/js/i18n.js" => "widget#i18n"
  get "/css/donate-button.css" => "widget#v1_css"
  get "/css/donate-button.v2.css" => "widget#v2_css"

  scope ActiveStorage.routes_prefix do
    get "/blobs/redirect/:signed_id/*filename" => "active_storage/blobs/redirect#show", :as => :rails_service_blob
    get "/blobs/proxy/:signed_id/*filename" => "active_storage/blobs/proxy#show", :as => :rails_service_blob_proxy
    get "/blobs/:signed_id/*filename" => "active_storage/blobs/redirect#show"

    get "/representations/redirect/:signed_blob_id/:variation_key/*filename" => "active_storage/representations/redirect#show", :as => :rails_blob_representation
    get "/representations/proxy/:signed_blob_id/:variation_key/*filename" => "active_storage/representations/proxy#show", :as => :rails_blob_representation_proxy
    get "/representations/:signed_blob_id/:variation_key/*filename" => "active_storage/representations/redirect#show"

    get "/disk/:encoded_key/*filename" => "active_storage/disk#show", :as => :rails_disk_service
    put "/disk/:encoded_token" => "active_storage/disk#update", :as => :update_rails_disk_service
    post "/direct_uploads" => "direct_uploads#create", :as => :rails_direct_uploads
  end

  direct :rails_representation do |representation, options|
    signed_blob_id = representation.blob.signed_id
    variation_key = representation.variation.key
    filename = representation.blob.filename

    route_for(:rails_blob_representation, signed_blob_id, variation_key, filename, options)
  end

  resolve("ActiveStorage::Variant") { |variant, options| route_for(ActiveStorage.resolve_model_to_route, variant, options) }
  resolve("ActiveStorage::VariantWithRecord") { |variant, options| route_for(ActiveStorage.resolve_model_to_route, variant, options) }
  resolve("ActiveStorage::Preview") { |preview, options| route_for(ActiveStorage.resolve_model_to_route, preview, options) }

  direct :rails_blob do |blob, options|
    route_for(:rails_service_blob, blob.signed_id, blob.filename, options)
  end

  resolve("ActiveStorage::Blob") { |blob, options| route_for(ActiveStorage.resolve_model_to_route, blob, options) }
  resolve("ActiveStorage::Attachment") { |attachment, options| route_for(ActiveStorage.resolve_model_to_route, attachment.blob, options) }

  direct :rails_storage_proxy do |model, options|
    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob_proxy,
        model.signed_id,
        model.filename,
        options
      )
    else
      signed_blob_id = model.blob.signed_id
      variation_key = model.variation.key
      filename = model.blob.filename

      route_for(
        :rails_blob_representation_proxy,
        signed_blob_id,
        variation_key,
        filename,
        options
      )
    end
  end

  direct :rails_storage_redirect do |model, options|
    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob,
        model.signed_id,
        model.filename,
        options
      )
    else
      signed_blob_id = model.blob.signed_id
      variation_key = model.variation.key
      filename = model.blob.filename

      route_for(
        :rails_blob_representation,
        signed_blob_id,
        variation_key,
        filename,
        options
      )
    end
  end
  root to: "front#index"
end
