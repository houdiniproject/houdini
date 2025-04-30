# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# based on https://github.com/jnunemaker/httparty/blob/b8f769e9f3133ec1dfa7fb2800ff3542d4248099/lib/httparty/logger/curl_formatter.rb which is
# under the following license:
# Copyright (c) 2008 John Nunemaker

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module HTTParty
  module Logger
    class CommitchangeLogger
      attr_accessor :level, :logger, :output_type

      def initialize(logger, level, output_type)
        @logger = logger
        @level = level.to_sym
        @output_type = output_type
        @messages = []
      end

      def format(request, response)
        @request = request
        @response = response

        log_request
        log_response

        logger.public_send level, JSON.generate(@output)
      end

      attr_reader :request, :response

      def output_hash
        @output ||= {
          type: output_type,
          request: {},
          response: {}
        }
      end

      def output_request
        output_hash[:request]
      end

      def output_response
        output_hash[:response]
      end

      def output_headers
        output_response[:headers] ||= {}
      end

      def log_request
        log_url
        log_headers
        log_query
        log_request_body
      end

      def log_url
        request.http_method.name.split("::").last.upcase
        uri = if request.options[:base_uri]
          request.options[:base_uri] + request.path.path
        else
          request.path.to_s
        end

        output_request[:url] = uri
      end

      def log_headers
        return unless request.options[:headers] && request.options[:headers].size > 0
        output_request[:headers] = request.options[:headers]
      end

      def log_query
        return unless request.options[:query]

        output_request[:query] = request.options[:query]
      end

      def log_request_body
        output_request[:body] = request.raw_body if request.raw_body
      end

      def log_response
        log_response_http_version
        log_response_code
        log_response_headers
        log_response_body
      end

      def log_response_http_version
        output_response[:http_version] = response.http_version
      end

      def log_response_code
        output_response[:response_code] = response.code
      end

      def log_response_headers
        headers = response.respond_to?(:headers) ? response.headers : response
        response.each_header do |response_header|
          output_headers[response_header] = headers[response_header]
        end
      end

      def log_response_body
        output_response[:body] = response.body
      end
    end
  end
end
