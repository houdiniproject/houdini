# frozen_string_literal: true

class RegisterNonprofitAndUser::SendNonprofitUserToMailchimp < Actor
  input :nonprofit
  input :user
  def call
    MailchimpNonprofitUserAddJob.perform_later( user, nonprofit )
  end
end
