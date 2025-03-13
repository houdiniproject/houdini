# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'houdini/v1/validations'
class Houdini::V1::API < Grape::API
	logger.formatter = GrapeLogging::Formatters::Rails.new
	use GrapeLogging::Middleware::RequestLogger, { logger: logger }
	content_type :json, 'application/json'
	default_format :json
	rescue_from Grape::Exceptions::ValidationErrors do |e|
		output = {errors: e}
		error! output, 400
	end

	#include Houdini::V1::Helpers::ApplicationHelper
	mount Houdini::V1::Nonprofit => '/nonprofit'
	# Additional mounts are added via generators above this line
  # DON'T REMOVE THIS OR THE PREVIOUS LINES!!!
end