# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchTodoStatus
  def self.for_profile(np)
    {
      has_logo: np.logo?,
      has_background: np.background_image?,
      has_summary: np.summary?,
      has_image: np.main_image?,
      has_highlight: np.has_achievements?,
      has_services: np.full_description?
    }
  end

  def self.for_dashboard(np)
    {
      has_campaign: np.campaigns.any?,
      has_event: np.events.any?,
      has_donation: np.donations.any?,
      has_branding: np.brand_color?,
      has_bank: np.bank_account.present?,
      is_paying: np.billing_plan.present?,
      has_imported: np.supporters.pluck(:imported_at).any?,
      is_verified: np.stripe_account&.verification_status == :verified && np.bank_account.present?,
      has_thank_you: np.thank_you_note.present?
    }
  end
end
