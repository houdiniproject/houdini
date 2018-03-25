class RecurringDonationMailer < BaseMailer

	def send_cancellation_notices(recurring_donation)
		UserMailer.recurring_donation_cancelled(recurring_donation).deliver
		NonprofitMailer.cancelled_recurring_donation(recurring_donation).deliver
		return recurring_donation
	end

	def send_failure_notifications(recurring_donation)
		UserMailer.recurring_donation_failure(recurring_donation).deliver
		NonprofitMailer.failed_recurring_donation(recurring_donation).deliver
	end
end
