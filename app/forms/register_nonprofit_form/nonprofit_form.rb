# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

class RegisterNonprofitForm::NonprofitForm < ApplicationForm
  attribute :name, :string, default: "" # needed because OnboardAccounts is goofy

  attr_reader :website
  attr_accessor :city,
    :email,
    :state_code,
    :phone,
    :zip_code

  validates :zip_code, presence: true
  validates :website, format: {with: URI::RFC2396_Parser.make_regexp}, if: proc { |form| form.website.present? }
  # validates :email, format: {with:  URI::MailTo::EMAIL_REGEXP }, if: Proc.new { |form| form.email.present? }

  def initialize(attributes = {})
    super
    @models = [
      nonprofit
    ]
  end

  def nonprofit
    @nonprofit ||= Nonprofit.new(OnboardAccounts.set_nonprofit_defaults(
      city: city,
      email: email,
      name: name,
      phone: phone,
      state_code: state_code,
      website: website,
      zip_code: zip_code
    ))
  end

  def website=(url)
    nudged_url = url
    unless url =~ /\Ahttp:\/\/.*/i || url =~ /\Ahttps:\/\/.*/i
      nudged_url = "http://" + url
    end
    @website = nudged_url
  end

  def valid?(context = nil)
    result = super
    unless result
      if nonprofit.errors.of_kind?(:slug, :taken)
        begin
          slug = ::SlugNonprofitNamingAlgorithm.new(nonprofit.state_code_slug, nonprofit.city_slug).create_copy_name(nonprofit.slug)
          nonprofit.slug = slug
          errors.delete(:slug, :taken)
          result = super # try again!
        rescue UnableToCreateNameCopyError
          errors.delete(:slug, :taken)
          errors.add(:name, :invalid, message: "has an invalid slug. Contact support for help.")
          result = false
        rescue
          # nothing, it's still false
        end
      end
    end

    result
  end
end
