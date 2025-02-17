# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def print_currency(cents, unit = "EUR", sign = true, use_precision = false)
    Format::Currency.print_currency(cents, unit, sign, use_precision)
  end

  def print_percent(rate)
    (rate.to_f * 100).round(2)
  end

  ## Dates

  # Format date to m/d/Y. Ex: 01/31/2022
  def format_date_to_mdY(date_object, timezone = nil)
    return "" if date_object.nil?

    date_object = date_object.in_time_zone(timezone) if timezone
    date_object.strftime("%m/%d/%Y")
  end

  def simple_time(time_object, timezone = nil)
    return "" if time_object.nil?

    time_object = time_object.in_time_zone(timezone) if timezone
    time_object.strftime("%l:%M%P")
  end

  # Format date with complete month name. Ex: "January 31, 2022"
  def format_date_with_month_name(date_object)
    date_object.strftime("%B %d, %Y")
  end

  # Format date to datetime with timezone. Ex: 01/31/2022 11:00PM (+03:00)
  def format_date_to_datetime_timezone(date_object, timezone = nil)
    date_object = date_object.in_time_zone(timezone) if timezone
    date_object.strftime("%m/%d/%Y %I:%M%P (%Z)")
  end

  def us_states
    [%w[Alabama AL], %w[Alaska AK], %w[Arizona AZ], %w[Arkansas AR], %w[California CA], %w[Colorado CO], %w[Connecticut CT], %w[Delaware DE], ["District of Columbia", "DC"], %w[Florida FL], %w[Georgia GA], %w[Hawaii HI], %w[Idaho ID], %w[Illinois IL], %w[Indiana IN], %w[Iowa IA], %w[Kansas KS], %w[Kentucky KY], %w[Louisiana LA], %w[Maine ME], %w[Maryland MD], %w[Massachusetts MA], %w[Michigan MI], %w[Minnesota MN], %w[Mississippi MS], %w[Missouri MO], %w[Montana MT], %w[Nebraska NE], %w[Nevada NV], ["New Hampshire", "NH"], ["New Jersey", "NJ"], ["New Mexico", "NM"], ["New York", "NY"], ["North Carolina", "NC"], ["North Dakota", "ND"], %w[Ohio OH], %w[Oklahoma OK], %w[Oregon OR], %w[Pennsylvania PA], ["Puerto Rico", "PR"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], %w[Tennessee TN], %w[Texas TX], %w[Utah UT], %w[Vermont VT], %w[Virginia VA], %w[Washington WA], ["West Virginia", "WV"], %w[Wisconsin WI], %w[Wyoming WY]]
  end

  # Prepend 'http://' if it is not present in a given url
  # Used for linking to nonprofit-provided website
  def add_http(url)
    if url[%r{^http://}] || url[%r{^https://}]
      url
    else
      "http://" + url
    end
  end
end
