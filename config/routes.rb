# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Rails.application.routes.draw do
 	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  if Rails.env == 'development'
    get '/button_debug/embedded' => 'button_debug#embedded'
    get '/button_debug/button' => 'button_debug#button'
    get '/button_debug/embedded/:id' => 'button_debug#embedded'
    get '/button_debug/button/:id' => 'button_debug#button'
  end
  get 'onboard' => 'onboard#index'

  defaults format: :json do # they're APIs, you have to use JSON
    namespace :api do
      resources :nonprofits, only: [:create]
    end
    namespace :api_new do
      resources :users, only: [] do
        get :current, on: :collection
        get :current_nonprofit_object_events, on: :collection
      end
      resources :nonprofits, only: [] do
        resources :object_events, only: [:index]
        resources :supporters, only: [:show]
        resources :transactions, only: %i[index show]
      end
    end
  end

  resources :emails, only: [:create]
  resources :settings, only: [:index]
  resources :campaign_gifts, only: [:create]
  resource :cards, only: %i[create update destroy]
  resource :direct_debit_details, path: 'sepa', controller: :direct_debit_details, only: [:create]

  # Creating presigned posts for direct-to-S3 upload
  resources :aws_presigned_posts, only: [:create]

  resources :image_attachments, only: [:create] do
    post :remove, on: :collection
  end

  resources :profiles, only: %i[show update] do
    member do
      get :fundraisers
      get :events
      get :donations_history
    end
  end

  namespace :nonprofits, path: 'nonprofits/:nonprofit_id' do
    resource :stripe_account, only: [:index] do
      get :index, format: :json
      get :verification
      get :confirm
      post :account_link, format: :json
      post :begin_verification, format: :json
    end
    resources :payouts, only: %i[create index show]
    resources :imports, only: [:create]
    resources :nonprofit_keys, only: [:index] do
      collection do
        get :mailchimp_login
        get :mailchimp_landing
      end
    end
    resources :reports, only: [] do
      collection do
        get :end_of_year
        get :end_of_year_custom
      end
    end
    resources :email_lists, only: %i[index create]
    resources :payments, only: %i[index show update destroy] do
      post :export, on: :collection
      member do
        post :resend_donor_receipt
        post :resend_admin_receipt
      end
    end
    resources :donations, only: %i[index show create update] do
      put :followup, on: :member
      post :create_offsite, on: :collection
    end
    resource :card, only: %i[edit update show create]

    resources :charges, only: [:index] do
      resources :refunds, only: %i[create index]
    end

    resource :bank_account, only: [:create] do
      get :confirmation
      post :confirm
      get :cancellation
      post :cancel
      post :resend_confirmation
    end

    resources :custom_field_masters, only: %i[index create destroy]
    resources :custom_field_joins, only: [] do
      post :modify, on: :collection
    end

    resources :tag_masters, only: %i[index create destroy]
    resources :tag_joins, only: [] do
      post :modify, on: :collection
    end

    resources :supporters, only: %i[index show create update new] do
      resources :tag_joins, only: %i[index destroy]
      resources :custom_field_joins, only: %i[index destroy]
      resources :supporter_notes, only: %i[create update destroy]
      resources :activities, only: [:index]
      collection do
        post :export
        put :bulk_delete
        post :merge
        get :merge_data
        get :index_metrics
      end
      member do
        get :info_card
        get :email_address
        get :full_contact
      end
    end

    resources :recurring_donations, only: %i[index show destroy update create] do
      post :export, on: :collection
    end

    resource :miscellaneous_np_info, only: %i[show update]

    namespace :button do
      root action: :advanced
      get :basic
      get :guided
      get :advanced
      post :send_code
    end

    post 'tracking', controller: 'trackings', action: 'create'
  end

  namespace :campaigns, path: '/nonprofits/:nonprofit_id/campaigns/:campaign_id/admin', only: [] do
    resources :supporters, only: [:index]
    resources :donations, only: [:index]
    resources :campaign_gift_options, only: [:index]
  end

  resources :nonprofits, only: %i[show create update destroy] do
    collection do
      post :onboard
      get :search
    end
    member do
      get :profile_todos
      get :recurring_donation_stats
      get :dashboard_todos
    end

    resources :roles, only: %i[create destroy]
    resources :settings, only: [:index]
    resources :pricing, only: [:index]
    resources :email_settings, only: %i[index create]
    resources :users, only: %i[index create] do
      resources :email_settings, only: %i[index create]
    end

    resources :campaigns, only: %i[index show create update] do
      member do
        get :metrics
        get :totals
        get :timeline
        post :duplicate
        get :activities
        put :soft_delete
      end
      collection do
        get :name_and_id
        post :create_from_template
      end
      resources :campaign_gift_options, only: %i[index show create update destroy] do
        put :update_order, on: :collection
      end
    end

    resource :billing_subscription, only: [:create] do
      post :cancel
      get :cancellation
    end

    resources :events, only: %i[index show create update] do
      member do
        get :metrics
        get :stats
        get :activities
        post :duplicate
      end
      collection do
        get :listings
        get :name_and_id, defaults: {format: :json}
      end

      put :soft_delete
      resources :tickets, only: %i[create update index destroy] do
        member do
          put :add_note
          post :delete_card_for_ticket
        end
      end
      resources :ticket_levels, only: %i[index show create update destroy] do
        put :update_order, on: :collection
      end
      resources :event_discounts, only: %i[create index update destroy]
    end

    member do
      get :donate
      get :btn
      get :supporter_form
      post :custom_supporter
      get :dashboard
      get :dashboard_metrics
      get :payment_history
      post :donate, as: 'create_donation'
    end
  end

  resources :recurring_donations, only: %i[edit destroy update] do
    put :update_amount, on: :member
  end

  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations',
               confirmations: 'users/confirmations'
             }
  devise_scope :user do
    match '/sign_in' => 'users/sessions#new', via: %i[get post]
    match '/signup' => 'devise/registrations#new', via: %i[get post]
    post '/confirm' => 'users/confirmations#confirm', via: [:get]
    match '/users/is_confirmed' => 'users/confirmations#is_confirmed', via: %i[get post]
    match '/users/exists' => 'users/confirmations#exists', via: [:get]
    post '/users/confirm_auth', action: :confirm_auth, controller: 'users/sessions', via: %i[get post]
  end

  # Super admin
  get '/admin' => 'super_admins#index', :as => 'admin'
  get '/admin/search-nonprofits' => 'super_admins#search_nonprofits'
  get '/admin/search-profiles' => 'super_admins#search_profiles'
  get '/admin/search-fullcontact' => 'super_admins#search_fullcontact'
  get '/admin/recurring-donations-without-cards' => 'super_admins#recurring_donations_without_cards'
  get '/admin/export_supporters_with_rds' => 'super_admins#export_supporters_with_rds'
  get '/admin/resend_user_confirmation' => 'super_admins#resend_user_confirmation'

  # Events
  get '/events' => 'events#index'
  get '/events/:event_slug' => 'events#show'

  defaults format: :json do
    post "/webhooks/stripe/receive" => "webhooks/stripe#receive"
    post "/webhooks/stripe/receive_connect" => "webhooks/stripe#receive_connect"
  end

  # Nonprofits
  get ':state_code/:city/:name' => 'nonprofits#show', :as => :nonprofit_location
  get ':state_code/:city/:name/donate' => 'nonprofits#donate', :as => :nonprofit_donation
  get ':state_code/:city/:name/button' => 'nonprofits/button#guided'

  # Campaigns
  get ':state_code/:city/:name/campaigns' => 'campaigns#index'
  get ':state_code/:city/:name/campaigns/:campaign_slug' => 'campaigns#show', :as => :campaign_loc
  get ':state_code/:city/:name/campaigns/:campaign_slug/supporters' => 'campaigns/supporters#index'
  get '/peer-to-peer' => 'campaigns#peer_to_peer'

  # Events
  get ':state_code/:city/:name/events' => 'events#index'
  get ':state_code/:city/:name/events/:event_slug' => 'events#show', as: :slugged_event
  get ':state_code/:city/:name/events/:event_slug/stats' => 'events#stats'
  get ':state_code/:city/:name/events/:event_slug/tickets' => 'tickets#index'
  # get '/events' => 'events#index'

  # Dashboard
  get ':state_code/:city/:name/dashboard' => 'nonprofits#dashboard', as: :np_dashboard

  # Misc
  get '/pages/wp-plugin', to: redirect('/help/wordpress-plugin') #temporary, until WP plugin updated

  # Maps
  get '/maps/all-npos' => 'maps#all_npos'
  get '/maps/all-supporters' => 'maps#all_supporters'
  get '/maps/all-npo-supporters' => 'maps#all_npo_supporters'
  get '/maps/specific-npo-supporters' => 'maps#specific_npo_supporters'

  # Mailchimp Landing
  get '/mailchimp-landing' => 'nonprofits/nonprofit_keys#mailchimp_landing'

  # Will create a slugged route for `Nonprofit`. So, if `nonprofit` is a `Nonprofit` with a state_code_slug: wi,
  # city_slug: appleton and slug: sample-commitchange-nonprofit, then `slugged_nonprofit_path(nonprofit)` would return:
  # /wi/appleton/sample-commitchange-nonprofit
  direct(:slugged_nonprofit) do |model, options|
    { controller: "nonprofits", action: "show", state_code: model.state_code_slug, city: model.city_slug, name: model.slug }.merge(options)
  end

  # Will create a slugged route for `Nonprofit`'s dashboard. So, if `nonprofit` is a `Nonprofit` with a state_code_slug: wi,
  # city_slug: appleton and slug: sample-commitchange-nonprofit, then `slugged_nonprofit_dashboard_path(nonprofit)` would 
  # return: /wi/appleton/sample-commitchange-nonprofit/dashboard
  direct(:slugged_nonprofit_dashboard) do |model, options|
    { controller: "nonprofits", action: "dashboard", state_code: model.state_code_slug, city: model.city_slug, name: model.slug }.merge(options)
  end

  # Webhooks
  get '/static/terms_and_privacy' => 'static#terms_and_privacy'
  get '/static/ccs' => 'static#ccs'
  get '/cloudflare_errors/under_attack' => 'cloudflare_errors#under_attack'

  root :to => 'front#index'
end
