# from https://github.com/rails/rails/blob/daa00c8357dc12ce24f89d92e4ceeabebb3af3d1/actionpack/lib/action_dispatch/middleware/cookies.rb
if Rails.version < '5'
  module ActionDispatch
    class Cookies
      module ChainedCookieJars
        class CookieJar 
          def handle_options(options) #:nodoc:
            options[:path] ||= "/"

            if options[:domain] == :all
              cookie_domain = ""
              dot_splitted_host = request.host.split('.', -1)

              # Case where request.host is not an IP address or it's an invalid domain
              # (ip confirms to the domain structure we expect so we explicitly check for ip)
              if request.host.match?(/^[\d.]+$/) || dot_splitted_host.include?("") || dot_splitted_host.length == 1
                options[:domain] = nil
                return
              end

              # If there is a provided tld length then we use it otherwise default domain.
              if options[:tld_length].present? 
                # Case where the tld_length provided is valid
                if dot_splitted_host.length >= options[:tld_length]
                  cookie_domain = dot_splitted_host.last(options[:tld_length]).join('.')
                end
              # Case where tld_length is not provided
              else
                # Regular TLDs
                if !(/([^.]{2,3}\.[^.]{2})$/.match?(request.host))
                  cookie_domain = dot_splitted_host.last(2).join('.')
                # **.**, ***.** style TLDs like co.uk and com.au
                else
                  cookie_domain = dot_splitted_host.last(3).join('.')
                end
              end

              options[:domain] = if cookie_domain.present?
                ".#{cookie_domain}"
              end
            elsif options[:domain].is_a? Array
              # if host matches one of the supplied domains without a dot in front of it
              options[:domain] = options[:domain].find {|domain| @host.include? domain.sub(/^\./, '') }
            end
          end
        end
      end
    end
  end

else
  raise "you need to review this"
end