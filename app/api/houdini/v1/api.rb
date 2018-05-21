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
	uriForHost = URI.parse(Settings.cdn.url)
	add_swagger_documentation \
		host: "#{uriForHost.host}#{Settings.cdn.port ? ":#{Settings.cdn.port}" : ""}",
		schemes: [uriForHost.scheme],
		base_path: '/api/v1'
end