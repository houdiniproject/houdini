# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe NonprofitsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'update' do
          include_context :open_to_np_associate, :put, :update, id: :__our_np
      end

      describe 'dashboard' do
          include_context :open_to_np_associate, :get, :dashboard, id: :__our_np
      end

      describe 'dashboard_metrics' do
          include_context :open_to_np_associate, :get, :dashboard_metrics, id: :__our_np
      end

      describe 'verify_identity' do
          include_context :open_to_np_associate, :put, :verify_identity, id: :__our_np
      end

      describe 'recurring_donation_stats' do
          include_context :open_to_np_associate, :get, :recurring_donation_stats, id: :__our_np
      end

      describe 'profile_todos' do
          include_context :open_to_np_associate, :get, :profile_todos, id: :__our_np
      end

      describe 'dashboard_todos' do
          include_context :open_to_np_associate, :get, :dashboard_todos, id: :__our_np
      end

      describe 'payment_history' do
          include_context :open_to_np_associate, :get, :payment_history, id: :__our_np
      end



      describe 'destroy' do
          include_context :open_to_super_admin, :delete, :destroy, id: :__our_np
      end
    end

    describe 'open to all' do
      describe 'show' do
          include_context :open_to_all, :get, :show, id: :__our_np
      end

      describe 'create' do
          include_context :open_to_all, :post, :create, nonprofit_id: :__our_np
      end

      describe 'btn' do
          include_context :open_to_all, :get, :btn, id: :__our_np
      end

      describe 'supporter_form' do
          include_context :open_to_all, :get, :supporter_form, id: :__our_np
      end

      describe 'custom_supporter' do
          include_context :open_to_all, :post, :custom_supporter, id: :__our_np
      end

      describe 'donate' do
          include_context :open_to_all, :get, :donate, id: :__our_np
      end

      describe 'search' do
        include_context :open_to_all, :get, :search
      end
    end
  end
end