# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# Create notice files for dependencies
namespace :notice do
    namespace :ruby do 
        require 'bundler'
        require 'httparty'
        def get_notice_ruby
            parser = Bundler::LockfileParser.new(File.read(Rails.root.join("Gemfile.lock")))
            result = parser.specs.map do |spec|
                "gem/rubygems/-/#{spec.name}/#{spec.version.to_s}"
            end

            @options = {
                :headers => {
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json'
                },
                :timeout => 120
            }
            result = HTTParty.post("https://api.clearlydefined.io/notices", @options.merge(body:JSON::generate({coordinates: result})))
            JSON::parse(result.body)['content']
        end

        desc "generating NOTICE-ruby from ClearlyDefined.io"
        task :update do
            result = get_notice_ruby
            File.write('NOTICE-ruby', result)
        end
        
        desc "checking whether NOTICE-ruby matches the one on ClearlyDefined.io"
        task :verify do
            result = get_notice_ruby
            raise "NOTICE-ruby is not up to date. Run bin/rails notice:ruby:update to update the file." if result != File.read('NOTICE-ruby')
        end
    end

    namespace :js do 
        require 'fileutils'
        def get_notice_js
            raise "NOTICE-js could not be retrieved from Clearlydefined.io" unless system('yarn noticeme')
            File.read('NOTICE')
        end

        desc "generating NOTICE-js from ClearlyDefined.io"
        task :update do
            if (File.exists?('NOTICE'))
                File.delete('NOTICE')
            end
            result = get_notice_js
            FileUtils.mv('NOTICE', 'NOTICE-js', force: true)
        end

        desc "checking whether NOTICE-js matches the one on ClearlyDefined.io"
        task :verify do
            result = get_notice_js
            raise "NOTICE-js is not up to date. Run bin/rails notice:js:update to update the file." if result != File.read('NOTICE-js')
        end
    end
end