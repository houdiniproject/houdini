# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Commitchange::Application.routes.draw do

  if Rails.env == 'development'
		get '/button_debug/embedded' => 'button_debug#embedded'
		get '/button_debug/button' => 'button_debug#button'
		get '/button_debug/embedded/:id' => 'button_debug#embedded'
		get '/button_debug/button/:id' => 'button_debug#button'
	end
	resources(:emails, {only: [:create]})
	resources(:settings, {only: [:index]})
	resources(:pricing, {only: [:index]})
	resources(:successes, {only: [:index]})
	resources(:campaign_gifts, {only: [:create]})
	resource(:cards, {only: [:create, :update, :destroy]})
	resource(:direct_debit_details, {path: 'sepa', controller: :direct_debit_details, only: [:create]})
 # resources(:activities, {only: [:create]})


  # Creating presigned posts for direct-to-S3 upload
  resources(:aws_presigned_posts, {only: [:create]})

	resources(:image_attachments, {only: [:create]}) do
		post(:remove, {on: :collection})
	end

	resources(:profiles, {only: [:show, :update]}) do
    get(:fundraisers, {on: :member})
    get(:events, {on: :member})
    get(:donations_history, {on: :member})
	end


	namespace(:nonprofits, {path: 'nonprofits/:nonprofit_id'}) do
		resources(:payouts, {only: [:create, :index, :show]})
		resources(:imports, {only: [:create]})
    resources(:nonprofit_keys, {only: [:index]}) do
      get(:mailchimp_login, {on: :collection})
      get(:mailchimp_landing, {on: :collection})
    end
    resources(:reports, {only: []}) do
      get(:end_of_year, {on: :collection})
			get(:end_of_year_custom, {on: :collection})
    end
    resources(:email_lists, {only: [:index, :create]})
    resources(:payments, {only: [:index, :show, :update, :destroy]}) do
			post(:export, {on: :collection})
      post(:resend_donor_receipt, {on: :member})
      post(:resend_admin_receipt, {on: :member})

    end
		resources(:donations, {only: [:index, :show, :create, :update]}) do
			put(:followup, {on: :member})
			post(:create_offsite, {on: :collection})
		end
    resource(:card, {only: [:edit, :update, :show, :create]})

		resources(:charges, {only: [:index]}) do
			resources(:refunds, {only: [:create, :index]})
		end

		resource(:bank_account, {only: [:create]}) do
			get(:confirmation)
			post(:confirm)
			get(:cancellation)
			post(:cancel)
			post(:resend_confirmation)
		end

		resources(:supporter_emails, {only: [:create, :show]}) do
      post(:gmail, {on: :collection})
    end

		resources(:custom_field_masters, {only: [:index, :create, :destroy]})
		resources(:custom_field_joins, {only: []}) do
			post(:modify, {on: :collection})
		end

		resources(:tag_masters, {only: [:index, :create, :destroy]})
		resources(:tag_joins, {only: []}) do
			post(:modify, {on: :collection})
		end

		resources(:supporters, {only: [:index, :show, :create, :update, :new]}) do
			resources(:tag_joins, {only: [:index, :destroy]})
			resources(:custom_field_joins, {only: [:index, :destroy]})
			resources(:supporter_notes, {only: [:create, :update, :destroy]})
      resources(:activities, {only: [:index]})
			put :bulk_delete, on: :collection
			post :merge, on: :collection
			get :merge_data, on: :collection
			get :info_card
			get :email_address
			get :full_contact
      get :index_metrics, on: :collection
		end

		resources(:recurring_donations, {only: [:index, :show, :destroy, :update, :create]}) do
			post(:export, on: :collection)
    end

    resource(:miscellaneous_np_info, {only: [:show, :update]})

		namespace(:button) do
			root({to: :advanced})
			get(:basic)
			get(:guided)
			get(:advanced)
			post(:send_code)
		end

    resources(:campaign_templates, {only: [:index, :create, :show, :destroy]})

		post 'tracking', controller: 'trackings', action: 'create'
	end

  namespace(:campaigns, {path: '/nonprofits/:nonprofit_id/campaigns/:campaign_id/admin', only: []}) do
    resources(:supporters, {only: [:index]})
    resources(:donations, {only: [:index]})
    resources(:campaign_gift_options, {only: [:index]})
  end

	resources(:nonprofits, {only: [:show, :create, :update, :destroy]}) do
    post(:onboard, {on: :collection})
		get(:profile_todos)
		get(:recurring_donation_stats)
    get(:search, {on: :collection})
		get(:dashboard_todos)
		put(:verify_identity)


		resources(:roles, {only: [:create, :destroy]})
		resources(:settings, {only: [:index]})
		resources(:pricing, {only: [:index]})
    resources(:email_settings, {only: [:index, :create]})
    resources(:users, {only: [:index, :create]}) do
      resources(:email_settings, {only: [:index, :create]})
    end

		resources(:campaigns, {only: [:index, :show, :create, :update]}) do
			get(:metrics, {on: :member})
			get(:totals, {on: :member})
			get(:timeline, {on: :member})
      post(:duplicate, {on: :member})
      get(:activities, {on: :member})
      put(:soft_delete, {on: :member})
      get(:name_and_id, {on: :collection})
			resources(:campaign_gift_options, {only: [:index, :show, :create, :update, :destroy]}) do
        put(:update_order, {on: :collection})
      end
		end

		resource(:billing_subscription, {only: [:create]}) do
			post(:cancel)
      post(:create_trial, {on: :member})
      get(:cancellation)
		end

		resources(:events, {only: [:index, :show, :create, :update]}) do
			get(:metrics, {on: :member})
			get(:listings, {on: :collection})
			get(:stats, {on: :member})
      get(:name_and_id, {on: :collection})
      get(:activities, {on: :member})
      post(:duplicate, {on: :member})
      put(:soft_delete)
			resources(:tickets, {only: [:create, :update, :index, :destroy]}) do
        put(:add_note, {on: :member})
        post(:delete_card_for_ticket, {on: :member})
			end
			resources(:ticket_levels, {only: [:index, :show, :create, :update, :destroy]}) do
        put(:update_order, {on: :collection})
      end
      resources(:event_discounts, {only: [:create, :index, :update, :destroy]})
		end

		get(:donate, {on: :member})
		get(:btn, {on: :member})
    get(:supporter_form, {on: :member})
    post(:custom_supporter, {on: :member})
		get(:dashboard, {on: :member})
		get(:dashboard_metrics, {on: :member})
		get(:payment_history, {on: :member})

		post(:donate, {on: :member, as: 'create_donation'})
	end

	resources(:recurring_donations, {only: [:edit, :destroy, :update]}) do
    put(:update_amount, {on: :member})
  end

	devise_for :users,
		:controllers => {
			:sessions => 'users/sessions',
			:registrations => 'users/registrations',
			:confirmations => 'users/confirmations'
		}
	devise_scope :user do
		match '/signin' => 'devise/sessions#new'
		match '/signup' => 'devise/registrations#new'
		post '/confirm' => 'users/confirmations#confirm'
    match '/users/is_confirmed' => 'users/confirmations#is_confirmed'
    match '/users/exists' => 'users/confirmations#exists'
		post '/users/confirm_auth', action: :confirm_auth, controller: 'users/sessions'
	end

	# Super admin
  match '/admin' => 'super_admins#index', :as => 'admin'
  match '/admin/search-nonprofits' => 'super_admins#search_nonprofits'
  match '/admin/search-profiles' => 'super_admins#search_profiles'
  match '/admin/search-fullcontact' => 'super_admins#search_fullcontact'
  match '/admin/recurring-donations-without-cards' => 'super_admins#recurring_donations_without_cards'
  match '/admin/export_supporters_with_rds' => 'super_admins#export_supporters_with_rds'
  match '/admin/resend_user_confirmation' => 'super_admins#resend_user_confirmation'

  # Events
  match '/events' => 'events#index'
  match '/events/:event_slug' => 'events#show'

	# Nonprofits
	match ':state_code/:city/:name' => 'nonprofits#show', :as => :nonprofit_location
	match ':state_code/:city/:name/donate' => 'nonprofits#donate', :as => :nonprofit_donation
	match ':state_code/:city/:name/button' => 'nonprofits/button#guided'

	# Campaigns
	match ':state_code/:city/:name/campaigns' => 'campaigns#index'
	match ':state_code/:city/:name/campaigns/:campaign_slug' => 'campaigns#show', :as => :campaign_loc
	match ':state_code/:city/:name/campaigns/:campaign_slug/supporters' => 'campaigns/supporters#index', :as => :campaign_loc
  match '/peer-to-peer' => 'campaigns#peer_to_peer'

	# Events
	match ':state_code/:city/:name/events' => 'events#index'
	match ':state_code/:city/:name/events/:event_slug' => 'events#show'
	match ':state_code/:city/:name/events/:event_slug/stats' => 'events#stats'
	match ':state_code/:city/:name/events/:event_slug/tickets' => 'tickets#index'
	# get '/events' => 'events#index'

	# Dashboard
	match ':state_code/:city/:name/dashboard' => 'nonprofits#dashboard', as: :np_dashboard

	# Misc
	get '/pages/wp-plugin', to: redirect('/help/wordpress-plugin') #temporary, until WP plugin updated

	# Maps
	get '/maps/all-npos' => 'maps#all_npos'
	get '/maps/all-supporters' => 'maps#all_supporters'
	get '/maps/all-npo-supporters' => 'maps#all_npo_supporters'
	get '/maps/specific-npo-supporters' => 'maps#specific_npo_supporters'

	# Mailchimp Landing
  match '/mailchimp-landing' => 'nonprofits/nonprofit_keys#mailchimp_landing'

  # Webhooks
  post '/webhooks/stripe_subscription_payment' => 'webhooks#subscription_payment'
  post '/webhooks/stripe' => 'webhooks#stripe'



	root :to => 'front#index'



end
