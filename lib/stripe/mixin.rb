# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Stripe::Mixin 
  extend ActiveSupport::Concern

  included do 
    def amex?
      brand == 'American Express'
    end

    def not_amex?
      !amex?
    end

    def domestic?(country='US')
      self.country == country
    end

    def foreign?(country='US')
      !domestic?(country)
    end
  end
end