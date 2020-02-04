require 'rails_helper'

RSpec.describe StripeAccount, :type => :model do
  describe "account should be pending" do
    let(:json) do
      %q({
        
        "id": "acct_1G8Y94CcxDUSisy4",
        "object": "account",
        "business_profile": {
          "mcc": "8398",
          "name": "Ending Poverty",
          "support_address": null,
          "support_email": null,
          "support_phone": null,
          "support_url": null,
          "url": null,
          "product_description": "Nonprofit donations"
        },
        "capabilities": {
          "card_payments": "pending",
          "legacy_payments": "inactive",
          "transfers": "inactive"
        },
        "charges_enabled": true,
        "country": "US",
        "default_currency": "usd",
        "details_submitted": false,
        "email": "fake@fake.com",
        "payouts_enabled": false,
        "settings": {
          "branding": {
            "icon": null,
            "logo": null,
            "primary_color": null
          },
          "card_payments": {
            "statement_descriptor_prefix": null,
            "decline_on": {
              "avs_failure": false,
              "cvc_failure": false
            }
          },
          "dashboard": {
            "display_name": null,
            "timezone": "Etc/UTC"
          },
          "payments": {
            "statement_descriptor": "",
            "statement_descriptor_kana": null,
            "statement_descriptor_kanji": null
          },
          "payouts": {
            "debit_negative_balances": false,
            "schedule": {
              "delay_days": 1,
              "interval": "manual"
            },
            "statement_descriptor": null
          }
        },
        "type": "custom",
        "business_type": "company",
        "company": {
          "address": {
            "city": "Appleton",
            "country": "US",
            "line1": "W2637 RUBY CT",
            "line2": null,
            "postal_code": "54915",
            "state": "WI"
          },
          "directors_provided": false,
          "executives_provided": false,
          "name": "Ending Poverty",
          "owners_provided": false,
          "phone": "+19205390404",
          "tax_id_provided": true,
          "verification": {
            "document": {
              "back": null,
              "details": null,
              "details_code": null,
              "front": null
            }
          }
        },
        "created": 1580848639,
        "external_accounts": {
          "object": "list",
          "data": [
          ],
          "has_more": false,
          "total_count": 0,
          "url": "/v1/accounts/acct_1G8Y94CcxDUSisy4/external_accounts"
        },
        "metadata": {
        },
        "requirements": {
          "current_deadline": null,
          "currently_due": [
            "external_account",
            "person_Gftx2SbD8oEptB.relationship.executive",
            "person_Gftx2SbD8oEptB.relationship.title",
            "relationship.owner",
            "tos_acceptance.date",
            "tos_acceptance.ip"
          ],
          "disabled_reason": "requirements.past_due",
          "eventually_due": [
            "external_account",
            "person_Gftx2SbD8oEptB.relationship.executive",
            "person_Gftx2SbD8oEptB.relationship.title",
            "relationship.owner",
            "tos_acceptance.date",
            "tos_acceptance.ip"
          ],
          "past_due": [
            "external_account",
            "person_Gftx2SbD8oEptB.relationship.executive",
            "person_Gftx2SbD8oEptB.relationship.title",
            "relationship.owner",
            "tos_acceptance.date",
            "tos_acceptance.ip"
          ],
          "pending_verification": [
            "person_Gftx2SbD8oEptB.verification.document"
          ]
        },
        "tos_acceptance": {
          "date": null,
          "ip": null,
          "user_agent": null
        }
      })
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is pending' do
      expect(sa.verification_status).to eq :pending
    end
    
  end
  describe 'account should be unverified' do
    let(:json) do
      %q({
        "id": "acct_1G8Y94CcxDUSisy4",
        "object": "account",
        "business_profile": {
          "mcc": "8398",
          "name": "Ending Poverty",
          "support_address": null,
          "support_email": null,
          "support_phone": null,
          "support_url": null,
          "url": null,
          "product_description": "Nonprofit donations"
        },
        "capabilities": {
          "card_payments": "pending",
          "legacy_payments": "inactive",
          "transfers": "inactive"
        },
        "charges_enabled": true,
        "country": "US",
        "default_currency": "usd",
        "details_submitted": false,
        "email": "fake@fake.com",
        "payouts_enabled": false,
        "settings": {
          "branding": {
            "icon": null,
            "logo": null,
            "primary_color": null
          },
          "card_payments": {
            "statement_descriptor_prefix": null,
            "decline_on": {
              "avs_failure": false,
              "cvc_failure": false
            }
          },
          "dashboard": {
            "display_name": null,
            "timezone": "Etc/UTC"
          },
          "payments": {
            "statement_descriptor": "",
            "statement_descriptor_kana": null,
            "statement_descriptor_kanji": null
          },
          "payouts": {
            "debit_negative_balances": false,
            "schedule": {
              "delay_days": 1,
              "interval": "manual"
            },
            "statement_descriptor": null
          }
        },
        "type": "custom",
        "business_type": "company",
        "company": {
          "address": {
            "city": "Appleton",
            "country": "US",
            "line1": "W2637 RUBY CT",
            "line2": null,
            "postal_code": "54915",
            "state": "WI"
          },
          "directors_provided": false,
          "executives_provided": false,
          "name": "Ending Poverty",
          "owners_provided": false,
          "phone": "+19205390404",
          "tax_id_provided": true,
          "verification": {
            "document": {
              "back": null,
              "details": null,
              "details_code": null,
              "front": null
            }
          }
        },
        "created": 1580848639,
        "external_accounts": {
          "object": "list",
          "data": [
          ],
          "has_more": false,
          "total_count": 0,
          "url": "/v1/accounts/acct_1G8Y94CcxDUSisy4/external_accounts"
        },
        "metadata": {
        },
        "requirements": {
          "current_deadline": null,
          "currently_due": [
            "external_account",
            "person_Gftx2SbD8oEptB.relationship.executive",
            "person_Gftx2SbD8oEptB.relationship.title",
            "relationship.owner",
            "tos_acceptance.date",
            "tos_acceptance.ip"
          ],
          "disabled_reason": "requirements.past_due",
          "eventually_due": [
            "external_account",
            "person_Gftx2SbD8oEptB.relationship.executive",
            "person_Gftx2SbD8oEptB.relationship.title",
            "relationship.owner",
            "tos_acceptance.date",
            "tos_acceptance.ip"
          ],
          "past_due": [
            "external_account",
            "person_Gftx2SbD8oEptB.relationship.executive",
            "person_Gftx2SbD8oEptB.relationship.title",
            "relationship.owner",
            "tos_acceptance.date",
            "tos_acceptance.ip",
            "person_Gftx2SbD8oEptB.verification.document"
          ],
          "pending_verification": [
            
          ]
        },
        "tos_acceptance": {
          "date": null,
          "ip": null,
          "user_agent": null
        }
      })
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is unverified' do
      expect(sa.verification_status).to eq :unverified
    end
  end

  describe 'account should be verified' do
    let(:json) do
      %q({
        "id": "acct_1G8Y94CcxDUSisy4",
        "object": "account",
        "business_profile": {
          "mcc": "8398",
          "name": "Ending Poverty",
          "support_address": null,
          "support_email": null,
          "support_phone": null,
          "support_url": null,
          "url": null,
          "product_description": "Nonprofit donations"
        },
        "capabilities": {
          "card_payments": "pending",
          "legacy_payments": "inactive",
          "transfers": "inactive"
        },
        "charges_enabled": true,
        "country": "US",
        "default_currency": "usd",
        "details_submitted": false,
        "email": "fake@fake.com",
        "payouts_enabled": false,
        "settings": {
          "branding": {
            "icon": null,
            "logo": null,
            "primary_color": null
          },
          "card_payments": {
            "statement_descriptor_prefix": null,
            "decline_on": {
              "avs_failure": false,
              "cvc_failure": false
            }
          },
          "dashboard": {
            "display_name": null,
            "timezone": "Etc/UTC"
          },
          "payments": {
            "statement_descriptor": "",
            "statement_descriptor_kana": null,
            "statement_descriptor_kanji": null
          },
          "payouts": {
            "debit_negative_balances": false,
            "schedule": {
              "delay_days": 1,
              "interval": "manual"
            },
            "statement_descriptor": null
          }
        },
        "type": "custom",
        "business_type": "company",
        "company": {
          "address": {
            "city": "Appleton",
            "country": "US",
            "line1": "W2637 RUBY CT",
            "line2": null,
            "postal_code": "54915",
            "state": "WI"
          },
          "directors_provided": false,
          "executives_provided": false,
          "name": "Ending Poverty",
          "owners_provided": false,
          "phone": "+19205390404",
          "tax_id_provided": true,
          "verification": {
            "document": {
              "back": null,
              "details": null,
              "details_code": null,
              "front": null
            }
          }
        },
        "created": 1580848639,
        "external_accounts": {
          "object": "list",
          "data": [
          ],
          "has_more": false,
          "total_count": 0,
          "url": "/v1/accounts/acct_1G8Y94CcxDUSisy4/external_accounts"
        },
        "metadata": {
        },
        "requirements": {
          "current_deadline": null,
          "currently_due": [
          ],
          "disabled_reason": "",
          "eventually_due": [
            "external_account"
          ],
          "past_due": [
            "external_account"
          ],
          "pending_verification": []
        },
        "tos_acceptance": {
          "date": null,
          "ip": null,
          "user_agent": null
        }
      }
    )
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is verified' do
      expect(sa.verification_status).to eq :verified
    end
  end
end
