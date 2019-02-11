# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignMailer < BaseMailer

	def creation_followup(campaign)
		@creator_profile = campaign.profile
		@campaign = campaign
		mail(:to => @creator_profile.user.email, :subject => "Get your new campaign rolling! (via #{Settings.general.name})")
	end

	def federated_creation_followup(campaign)
		@creator_profile = campaign.profile
		@campaign = campaign
		mail(:to => @creator_profile.user.email, :subject => "Get your new campaign rolling! (via #{Settings.general.name})")
	end
end
