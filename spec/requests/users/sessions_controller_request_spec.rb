# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do
  it 'has X-Frame-Options=SAMEORIGIN set' do
    get '/users/sign_in'

    expect(response.headers['X-Frame-Options']).to eq 'SAMEORIGIN'
  end
end