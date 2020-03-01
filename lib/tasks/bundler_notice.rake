# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
desc "generating a notice for bundler"

# Clear old activerecord sessions tables daily
task :bundler_notice => :environment do
    require 'bundler'
    require 'httparty'
    parser = Bundler::LockfileParser.new(File.read(Rails.root.join("Gemfile.lock")))
    result = parser.specs.map do |spec|
        "gem/rubygems/-/#{spec.name}/#{spec.version.to_s}"
    end

    @options = {
        :headers => {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
        }
    }

    result = HTTParty.post("https://api.clearlydefined.io/notices", @options.merge(body:JSON::generate({coordinates: result})))
    byebug
end