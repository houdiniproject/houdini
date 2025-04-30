# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QuerySourceToken
  EXPIRED_TOKEN_MESSAGE = "There was an error processing your card and it was not charged. Please try again."
  AUTH_ERROR_MESSAGE = "You're not authorized to make this charge"

  # @param [String] source_token
  # @param [User] user the current user
  # @return [SourceToken] the token object
  # @raise [ParamValidation::ValidationError] when the source_token can't be found
  # @raise [AuthenticationError] when user isn't authorized to use that token
  # @raise [ExpiredTokenError] when the source token has already been used too many times
  #           or we're past the expiration date
  def self.get_and_increment_source_token(token, user = nil)
    ParamValidation.new({token: token}, {
      token: {required: true, format: UUID::Regex}
    })
    source_token = SourceToken.where("token = ?", token).first
    if source_token
      source_token.with_lock {
        unless source_token_unexpired?(source_token)
          raise ExpiredTokenError.new(EXPIRED_TOKEN_MESSAGE)
        end

        if source_token.event
          unless user
            raise AuthenticationError.new AUTH_ERROR_MESSAGE
          end

          unless QueryRoles.is_authorized_for_nonprofit?(user.id, source_token.event.nonprofit.id)
            raise AuthenticationError.new AUTH_ERROR_MESSAGE
          end
        end
        source_token.total_uses = source_token.total_uses + 1
        source_token.save!
      }
    else
      raise ParamValidation::ValidationError.new "#{token} doesn't represent a valid source", {key: :token}
    end

    source_token
  end

  def self.source_token_unexpired?(source_token)
    if source_token.max_uses <= source_token.total_uses
      return false
    end
    if source_token.expiration < Time.now
      return false
    end
    true
  end

  def self.validate_source_token_type(source_token)
    tokenizable = source_token.tokenizable
    unless tokenizable.is_a? Card
      raise ParamValidation::ValidationError.new("The item for token #{data[:token]} is not a Card", key: :token)
    end
  end
end
