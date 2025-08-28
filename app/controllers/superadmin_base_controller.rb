# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# an abstract controller used by the maintenance_tasks endpoint to
# protect it
class SuperadminBaseController < ApplicationController
  abstract!
  before_action :authenticate_super_admin!
end
