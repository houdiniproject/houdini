# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Load the Rails application
require_relative 'application'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
@ignore_dotenv = ENV['IGNORE_DOTENV']
@env = Rails.env || 'development'
unless (@ignore_dotenv)
  require 'dotenv'
  if @env == 'test'
    if File.file?(".env.#{@env}")
      Dotenv.load ".env.#{@env}"
    end
  else
    Dotenv.load ".env"
  end
end

@org_name = ENV['ORG_NAME'] || 'default_organization'
puts "config files .env .env.#{@env} ./config/settings.#{@env}.yml#{ @env != 'test' ? " ./config/#{@org_name}.yml": " "}  #{ @env != 'test' ? " ./config/#{@org_name}.#{@env}.yml": " "} #{ @env == 'test' ? "./config/settings.test.yml" : ""}"
if Rails.env == 'test'
  Settings.add_source!("./config/settings.test.yml")
else
  Settings.add_source!("./config/#{@org_name}.yml")
  Settings.add_source!("./config/#{@org_name}.#{Rails.env}.yml")
end



#Settings.add_source!("./config/#{@org_name}.#{Rails.env}.yml")

#we load the schema now because we didn't want to do so until we loaded EVERYTHING
Config.schema do

  required(:general).schema do
    # the name of your website. Default in Settings is "Houdini Project"
    required(:name).filled(:str?)

    # the relative path from asset_host root where your small logo (bug-sized logo) is set
    required(:logo).filled(:str?)

    # the relative path from asset_host root where your big logo
    required(:logo_full).filled(:str?)

    # the relative path from asset_host root to your poweredby email logo (PNG, 150px wide)
    required(:poweredby_logo).filled(:str?)

  end

  required(:default).schema do
    required(:image).schema do
      #the path on your image.host to your default profile image
      required(:profile).filled(:str?)

      #the path on your image.host to your default nonprofit image
      required(:nonprofit).filled(:str?)

      #the path on your image.host to your default campaign background image
      required(:campaign).filled(:str?)
    end

    # the cache stor you're using. Must be the name of caching store for rails
    # Default is dalli_store
    required(:cache_store).filled(:str?)
  end

  required(:aws).schema do
    # the region your AWS bucket is in
    optional(:region).filled(:str?)

    # the name of your aws bucket
    required(:bucket).filled(:str?)

    # your AWS access key. Set from AWS_ACCESS_KEY ENV variable
    required(:access_key_id).filled(:str?)

    # your AWS secret access key. Set from AWS_SECRET_ACCESS_KEY ENV variable
    required(:secret_access_key).filled(:str?)
  end

  required(:mailer).schema do
    #an action mailer delivery method
    # Default is sendmail
    required(:delivery_method).filled(:str?)

    # SMTP server address
    # Default is localhost
    required(:address).filled(:str?)

    # Port for SMTP server
    # Default is 25
    required(:port).filled(:int?)

    # Default host for links in email
    # Default is http://localhost
    required(:host).filled(:str?)
  end

  optional(:image).schema do
    # Your AWS image host url.
    # Default is https://s3-#{Settings.aws.region}.amazonaws.com/#{Settings.aws.bucket}
    required(:host).filled(:str?)
  end

  required(:cdn).schema do
    # URL for your CDN for assets. Usually this is just your url
    # Default is http://localhost:8080
    required(:url).filled(:str?)
  end

  required(:payment_provider).schema do
    # Your stripe public key
    # Default is STRIPE_API_PUBLIC ENV variable
    required(:stripe_public_key).filled(:str?)

    # Your Stripe_private key
    # Default is STRIPE_API_PRIVATE ENV variable
    required(:stripe_private_key).filled(:str?)

    # Whether you want to use the Stripe v2 js file instead of
    # of the open source replacement
    # Default is false
    optional(:stripe_proprietary_v2_js).filled(:bool?)

    # Whether you want to use Stripe Connect so that every nonprofit account to be
    # associated account of a main Stripe account. (Like CommitChange)
    # Default is false
    optional(:stripe_connect).filled(:bool?)
  end

  optional(:maps).schema do
    # the map provider to use. Currently that's just Google Maps or nothing
    # Default is nil
    optional(:provider).value(included_in?:['google', nil])

    optional(:options).schema do
      #key for your google maps instance
      optional(:key).filled(:str?)
    end
  end

  required(:page_editor).schema do
    # The editor used for editing nonprofit, campaign
    # and event pages and some email templates
    # Default is 'quill'
    required(:editor).value(included_in?:['quill', 'froala'])

    optional(:editor_options).schema do

      # Froala Key if your use froala
      # Default is nil (you need to get a key)
      required(:froala_key).filled(:str?)
    end
  end

  required(:source_tokens).schema do
    # The max number of times a source token can be used before expiring
    # Default is 1
    required(:max_uses).filled(:int?)

    # The time in seconds before a source token expires regardless if used max_time
    # Default is 1200 (20 minutes)
    required(:expiration_time).filled(:int?)

    #event donation source tokens are unique.
    # The idea is someone may want to donate multiple times at an event without
    # staff needing to enter their info again. Additionally, they
    # may want to do it after the event without staff
    # needing to reenter info
    required(:event_donation_source).schema do
      # max number of times an event source toiken can be used before expiring
      # Default is 20
      required(:max_uses).filled(:int?)

      # The time (in seconds) after an event ends that this token can be used.
      # Default is 1728000 (20 days)
      required(:time_after_event).filled(:int?)

    end
  end

  #sets the default language for the UI
  required(:language).filled(:str?)

  #sets the list of locales available
  required(:available_locales).each(:str?)

  # your default language needs to be in the available locales
  rule(make_sure_language_in_locales: [:language, :available_locales]) do |language, available_locales|
    language.included_in?(available_locales)
  end

  # TODO have a way to validate the available_locales are actually available translations

  # Whether to show state fields in the donation wizard
  optional(:show_state_fields).filled(:bool?)


  required(:intntl).schema do
    # the supporter currencies for the site as abbreviations
    required(:currencies).each(:str?)

    # the definition of the currencies
    required(:all_currencies).each do
      # each currency must have the following

        # the unit. For 'usd', this would be "dollars"
        required(:unit).filled(:str?)
        # the abbreviation of the currency. For 'usd', this would be "usd"
        required(:abbv).filled(:str?)
        # the subunit of the currency. For 'usd', this would be "cents"
        required(:subunit).filled(:str?)
        # the currency symbol of the currency. For 'usd', this would be "$"
        required(:symbol).filled(:str?)

        required(:format).filled(:str?)

    end

    # an array of country codes to override the default set of countries
    # If not set, the default is the list of countries in the class ISO3166
    # from the countries gem
    optional(:all_countries).each(:str?)

    # additional countries to add to the country list?
    optional(:other_country).filled(:str?)

    # Xavier, I need you document this :)
    optional(:integration)


  end

  required(:default_bp).schema do
    # the id of the default billing plan
    # Default is 1 (which is seeded)
    required(:id).filled(:int?)
  end

  # whether nonprofits must be vetted before they can use the service.
  optional(:nonprofits_must_be_vetted).filled(:bool?)

  optional(:terms_and_privacy).schema do
    # the url to the terms of use of this Houdini Project instance
    optional(:terms_url).filled(:str?)

    # the url to the privacy policy of this Houdini Project instance
    optional(:privacy_url).filled(:str?)

    # the url to the help page of this Houdini Project instance
    optional(:help_url).filled(:str?)

    # the url to the about page of this Houdini Project instance
    optional(:about_url).filled(:str?)
  end

  # complete, corresponding source
  optional(:ccs).schema do
    optional(:ccs_method).value(included_in?: %w(local_tar_gz github))

    # only used for github
    # NOTE: for github you need to have the hash of the corresponding source in $RAILS_ROOT/CCS_HASH
    optional(:options).schema do
      # the account of the repository to find the code
      required(:account).filled(:str?)
      # the name of the repo to find the code
      required(:repo).filled(:str?)
    end
  end

  # the settings to get into maintenance_mode
  optional(:maintenance).schema do
    # true if you want to be in maintenance mode, otherwise false
    optional(:maintenance_mode).filled(:bool?)

    # the token you pass into /users/sign_in to actually get to
    # a signin page during maintenance mode
    optional(:maintenance_token).filled(:str?)

    # the url, absolute or relative, that visitors should be redirected to
    optional(:maintenance_page).filled(:str?)

  end

  #the url for your button. As a default, it takes what's in CDN.url
  optional(:button_domain).schema do
    required(:url).filled?(:str)
  end

  # the domain for your api. Usually will be your CDN.url
  optional(:api_domain).schema do
    required(:url).filled?(:str)
  end

end

Settings.reload!

# Initialize the rails application
Rails.application.initialize!
