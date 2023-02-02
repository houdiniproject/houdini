# from Rails 6.1.7.1

if Rails.version < '6.1.7.1'
  module ActionDispatch
    module Http
      module Cache
        module Request
          # backport for CVE-2023-22795
          def if_none_match_etags
            (if_none_match ? if_none_match.split(",").each(&:strip!) : []).collect do |etag|
              etag.gsub(/^\"|\"$/, "")
            end
          end
        end
      end
    end
  end
end