# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StateCodeConstraint
  US_STATES = %w(AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN 
      IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ 
      NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VA WA WV WI WY)
  US_STATES_REGEX = Regexp.union(*US_STATES.map{|i| /^#{i.downcase}$/})

  def matches?(request)
    US_STATES_REGEX =~ request.params[:state_code]
  end
end