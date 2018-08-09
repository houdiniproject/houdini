# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'houdini/v1/validations'
class Houdini::V1::API < Grape::API
	helpers Houdini::V1::Helpers::RescueHelper
	# rescue_froms HAVE to be a the top
	rescue_from Grape::Exceptions::ValidationErrors do |e|
		validation_errors_output(e)
	end

	rescue_from ActiveRecord::RecordInvalid do |e|
		rescue_ar_invalid(e)
	end

	mount Houdini::V1::Address => '/address'
	mount Houdini::V1::Nonprofit => '/nonprofit'
	# Additional mounts are added via generators above this line
  # DON'T REMOVE THIS OR THE PREVIOUS LINES!!!
	logger.formatter = GrapeLogging::Formatters::Rails.new
	use GrapeLogging::Middleware::RequestLogger, { logger: logger }
	content_type :json, 'application/json'
	default_format :json

	uri_for_host = URI.parse(Settings.api_domain&.url || Settings.cdn.url)
	
	add_swagger_documentation \
		host: "#{uri_for_host.host}#{uri_for_host.port ? ":#{uri_for_host.port}" : ""}",
		schemes: [uri_for_host.scheme],
		base_path: '/api/v1'
end