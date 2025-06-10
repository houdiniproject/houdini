# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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

  def print_currency(cents, unit = "EUR", sign = true)
    dollars = cents.to_f / 100.0
    dollars = number_to_currency(dollars, unit: "#{unit}", precision: (dollars.round == dollars) ? 0 : 2)
    dollars = dollars[1..-1] if !sign
    dollars
  end

  def print_percent(rate)
    (rate.to_f * 100).round(2)
  end

  ## Dates

  def simple_date date_object, timezone = nil
    return "" if date_object.nil?
    date_object = date_object.in_time_zone(timezone) if timezone
    date_object.strftime("%m/%d/%Y")
  end

  def readable_date date_object
    date_object.strftime("%B %d, %Y")
  end

  def date_and_time date_object, timezone = nil
    date_object = date_object.in_time_zone(timezone) if timezone
    date_object.strftime("%m/%d/%Y %I:%M%P (%Z)")
  end

  def us_states
    [["Alabama", "AL"], ["Alaska", "AK"], ["Arizona", "AZ"], ["Arkansas", "AR"], ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["Delaware", "DE"], ["District of Columbia", "DC"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Iowa", "IA"], ["Kansas", "KS"], ["Kentucky", "KY"], ["Louisiana", "LA"], ["Maine", "ME"], ["Maryland", "MD"], ["Massachusetts", "MA"], ["Michigan", "MI"], ["Minnesota", "MN"], ["Mississippi", "MS"], ["Missouri", "MO"], ["Montana", "MT"], ["Nebraska", "NE"], ["Nevada", "NV"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], ["New Mexico", "NM"], ["New York", "NY"], ["North Carolina", "NC"], ["North Dakota", "ND"], ["Ohio", "OH"], ["Oklahoma", "OK"], ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Puerto Rico", "PR"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Vermont", "VT"], ["Virginia", "VA"], ["Washington", "WA"], ["West Virginia", "WV"], ["Wisconsin", "WI"], ["Wyoming", "WY"]]
  end

  # Prepend 'http://' if it is not present in a given url
  # Used for linking to nonprofit-provided website
  def add_http url
    if url[/^http:\/\//] || url[/^https:\/\//]
      url
    else
      "http://" + url
    end
  end

  def twitter_share(event_name)
    twitter_url = "https://twitter.com/intent/tweet?#{
      {
        url: request.original_url,
        via: "CommitChange",
        text: "I support #{event_name}"
      }.to_param
    }"

    link_options = {
      class: "button--circle--large twitter",
      target: "_blank"
    }

    content_tag :div do
      link_to(twitter_url, link_options) do
        tag.i(class: "fa fa-1x fa-twitter")
      end +
      content_tag(:p, "Tweet")
    end
  end


  def facebook_share(url)
    link_options = {
      class: "button--circle--large facebook",
      target: "_blank"
    }

    facebook_url = "https://www.facebook.com/sharer/sharer.php?#{ {  u: url }.to_param }"

    content_tag :div do
      link_to(facebook_url, link_options) do
        tag.i(class: "fa fa-facebook")
      end +
      content_tag(:p, "Share")
    end
  end
end
