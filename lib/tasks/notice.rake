# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# Create notice files for dependencies
namespace :notice do
  desc "generate NOTICE-ruby and NOTICE-js"
  task update: ["ruby:update", "js:update"]
  namespace :ruby do
    require "bundler"
    require "httparty"
    def get_notice_ruby
      parser = Bundler::LockfileParser.new(File.read(Rails.root.join("Gemfile.lock")))
      result = parser.specs.map do |spec|
        "gem/rubygems/-/#{spec.name}/#{spec.version}"
      end

      @options = {
        headers: {
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        },
        timeout: 120
      }
      result = HTTParty.post("https://api.clearlydefined.io/notices", @options.merge(body: JSON.generate({coordinates: result})))
      JSON.parse(result.body)["content"]
    end

    desc "generating NOTICE-ruby from ClearlyDefined.io"
    task :update do
      result = get_notice_ruby
      File.write("NOTICE-ruby", result)
    end

    desc "checking whether NOTICE-ruby matches the one on ClearlyDefined.io"
    task :verify do
      result = get_notice_ruby
      raise "NOTICE-ruby is not up to date. Run bin/rails notice:ruby:update to update the file." if result != File.read("NOTICE-ruby")
    end
  end

  namespace :js do
    notice_cmd = "yarn notice:js"

    desc "generating NOTICE-js from ClearlyDefined.io"
    task :update do
      raise "NOTICE-js could not be updated" unless system(notice_cmd + " -u")
    end

    desc "checking whether NOTICE-js matches the one on ClearlyDefined.io"
    task :verify do
      raise "NOTICE-js is not up to date. Run bin/rails notice:js:update to update the file" unless system(notice_cmd)
    end
  end
end
