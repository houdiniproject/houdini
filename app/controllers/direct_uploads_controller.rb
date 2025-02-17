# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class DirectUploadsController < ActiveStorage::DirectUploadsController
  include Controllers::Nonprofit::Authorization
  skip_before_action :verify_authenticity_token, only: [:create] # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :authenticate_confirmed_user!
end
