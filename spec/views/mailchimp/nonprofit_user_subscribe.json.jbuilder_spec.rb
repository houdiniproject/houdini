# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later 
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe '/mailchimp/nonprofit_user_subscribe.json.jbuilder', type: :view do
  
  describe 'adding new subscriber to nonprofit list' do 

    subject(:json) do 
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(1)
      user = create(:user_as_nonprofit_associate) 
      assign(:user, user)
      assign(:nonprofit, user.roles.first.host)
      render
      rendered
    end 

    it {
      is_expected.to include_json(
        email_address: User.first.email,
        status: 'subscribed',
        merge_fields: {
          NONPROFIT_ID: User.first.roles.first.host.id
        }
      )
    }
  end 

end 
