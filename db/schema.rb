# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_07_15_004028) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "supporter_id"
    t.integer "host_id"
    t.string "host_type", limit: 255
    t.string "action_type", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "attachment_id"
    t.string "attachment_type", limit: 255
    t.integer "nonprofit_id"
    t.boolean "public"
    t.integer "user_id"
    t.datetime "date", precision: nil
    t.string "kind", limit: 255
    t.jsonb "json_data"
    t.index ["attachment_type", "attachment_id"], name: "index_activities_on_attachment_type_and_attachment_id"
    t.index ["nonprofit_id"], name: "index_activities_on_nonprofit_id"
    t.index ["supporter_id"], name: "index_activities_on_supporter_id"
  end

  create_table "bank_accounts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "account_number", limit: 255
    t.string "bank_name", limit: 255
    t.string "email", limit: 255
    t.integer "nonprofit_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "pending_verification"
    t.string "confirmation_token", limit: 255
    t.string "status", limit: 255
    t.string "stripe_bank_account_token", limit: 255
    t.string "stripe_bank_account_id", limit: 255
    t.boolean "deleted", default: false
  end

  create_table "billing_plans", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "stripe_plan_id", limit: 255
    t.integer "amount"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "interval", limit: 255
    t.decimal "percentage_fee", default: "0.0", null: false
    t.integer "flat_fee", default: 0, null: false
  end

  create_table "billing_subscriptions", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id"
    t.integer "billing_plan_id"
    t.string "stripe_subscription_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status", limit: 255
    t.index ["nonprofit_id", "billing_plan_id"], name: "index_billing_subscriptions_on_nonprofit_id_and_billing_plan_id"
    t.index ["nonprofit_id"], name: "index_billing_subscriptions_on_nonprofit_id"
  end

  create_table "campaign_gift_options", id: :serial, force: :cascade do |t|
    t.integer "amount_one_time"
    t.text "description"
    t.string "name", limit: 255
    t.integer "campaign_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "amount_dollars", limit: 255
    t.integer "amount_recurring"
    t.integer "quantity"
    t.boolean "to_ship"
    t.integer "order"
    t.boolean "hide_contributions"
  end

  create_table "campaign_gifts", id: :serial, force: :cascade do |t|
    t.integer "donation_id"
    t.integer "campaign_gift_option_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "recurring_donation_id"
    t.index ["campaign_gift_option_id"], name: "index_campaign_gifts_on_campaign_gift_option_id"
    t.index ["donation_id"], name: "index_campaign_gifts_on_donation_id"
  end

  create_table "campaigns", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "url", limit: 255
    t.integer "total_raised"
    t.integer "goal_amount"
    t.integer "nonprofit_id"
    t.integer "profile_id"
    t.string "main_image", limit: 255
    t.string "vimeo_video_id", limit: 255
    t.text "summary"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "published"
    t.string "background_image", limit: 255
    t.integer "total_supporters"
    t.string "slug", limit: 255
    t.string "youtube_video_id", limit: 255
    t.string "tagline", limit: 255
    t.text "video_url"
    t.boolean "show_total_raised", default: true
    t.boolean "show_total_count", default: true
    t.boolean "hide_activity_feed"
    t.boolean "deleted", default: false
    t.boolean "hide_title"
    t.boolean "hide_thermometer"
    t.boolean "hide_goal"
    t.text "receipt_message"
    t.boolean "hide_custom_amounts"
    t.boolean "show_recurring_amount", default: false
    t.datetime "end_datetime", precision: nil
    t.string "external_identifier", limit: 255
    t.boolean "goal_is_in_supporters"
    t.integer "starting_point"
    t.integer "parent_campaign_id"
    t.text "reason_for_supporting"
    t.text "default_reason_for_supporting"
    t.string "banner_image", limit: 255
    t.integer "widget_description_id"
    t.index ["parent_campaign_id"], name: "index_campaigns_on_parent_campaign_id"
    t.index ["widget_description_id"], name: "index_campaigns_on_widget_description_id"
  end

  create_table "cards", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status", limit: 255
    t.integer "profile_id"
    t.string "email", limit: 255
    t.integer "expiration_month"
    t.integer "expiration_year"
    t.integer "supporter_id"
    t.string "stripe_card_token", limit: 255
    t.string "stripe_card_id", limit: 255
    t.integer "holder_id"
    t.string "holder_type", limit: 255
    t.string "stripe_customer_id", limit: 255
    t.boolean "deleted", default: false
    t.boolean "inactive"
    t.string "country", limit: 255
    t.index ["holder_id", "holder_type"], name: "index_cards_on_holder_id_and_holder_type"
    t.index ["id", "holder_type", "holder_id", "inactive"], name: "index_cards_on_id_and_holder_type_and_holder_id_and_inactive"
  end

  create_table "charges", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.string "stripe_charge_id", limit: 255
    t.boolean "disbursed"
    t.string "failure_message", limit: 255
    t.integer "card_id"
    t.integer "nonprofit_id"
    t.integer "supporter_id"
    t.integer "profile_id"
    t.integer "donation_id"
    t.integer "ticket_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "payment_id"
    t.string "status", limit: 255
    t.integer "fee"
    t.integer "direct_debit_detail_id"
    t.index ["donation_id"], name: "index_charges_on_donation_id"
    t.index ["payment_id"], name: "index_charges_on_payment_id"
  end

  create_table "custom_field_joins", id: :serial, force: :cascade do |t|
    t.integer "custom_field_master_id"
    t.integer "supporter_id"
    t.text "value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["custom_field_master_id", "supporter_id"], name: "custom_field_join_supporter_unique_idx", unique: true
    t.index ["custom_field_master_id"], name: "custom_field_joins_custom_field_master_id"
    t.index ["supporter_id"], name: "index_custom_field_joins_on_supporter_id"
  end

  create_table "custom_field_masters", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "nonprofit_id"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["nonprofit_id"], name: "index_custom_field_masters_on_nonprofit_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "direct_debit_details", id: :serial, force: :cascade do |t|
    t.string "iban", limit: 255
    t.string "account_holder_name", limit: 255
    t.string "bic", limit: 255
    t.integer "holder_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "dispute_payment_backups", id: :serial, force: :cascade do |t|
    t.integer "dispute_id"
    t.integer "payment_id"
  end

  create_table "dispute_transactions", id: :serial, force: :cascade do |t|
    t.integer "dispute_id"
    t.integer "payment_id"
    t.integer "gross_amount", default: 0
    t.integer "fee_total", default: 0
    t.integer "net_amount", default: 0
    t.boolean "disbursed", default: false
    t.string "stripe_transaction_id", limit: 255
    t.datetime "date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["dispute_id"], name: "index_dispute_transactions_on_dispute_id"
    t.index ["payment_id"], name: "index_dispute_transactions_on_payment_id"
  end

  create_table "disputes", id: :serial, force: :cascade do |t|
    t.integer "gross_amount"
    t.integer "charge_id"
    t.string "reason", limit: 255
    t.string "status", limit: 255
    t.string "stripe_dispute_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "started_at", precision: nil
    t.boolean "is_legacy", default: false
    t.index ["stripe_dispute_id"], name: "index_disputes_on_stripe_dispute_id", unique: true
  end

  create_table "donations", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.integer "profile_id"
    t.integer "nonprofit_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "card_id"
    t.text "designation"
    t.boolean "offsite"
    t.boolean "anonymous", default: false, null: false
    t.integer "supporter_id"
    t.text "origin_url"
    t.boolean "manual"
    t.integer "campaign_id"
    t.integer "recurring_donation_id"
    t.text "comment"
    t.boolean "recurring"
    t.text "dedication"
    t.integer "event_id"
    t.datetime "imported_at", precision: nil
    t.integer "charge_id"
    t.integer "payment_id"
    t.string "category", limit: 255
    t.datetime "date", precision: nil
    t.datetime "queued_for_import_at", precision: nil
    t.integer "direct_debit_detail_id"
    t.string "payment_provider", limit: 255
    t.tsvector "fts"
    t.index "lower(designation)", name: "donations_designation"
    t.index ["amount"], name: "donations_amount"
    t.index ["anonymous"], name: "index_donations_on_anonymous"
    t.index ["campaign_id"], name: "donations_campaign_id"
    t.index ["event_id"], name: "donations_event_id"
    t.index ["event_id"], name: "index_donations_on_event_id"
    t.index ["fts"], name: "donations_fts_idx", using: :gin
    t.index ["nonprofit_id"], name: "index_donations_on_nonprofit_id"
    t.index ["supporter_id"], name: "donations_supporter_id"
  end

  create_table "donations_payment_imports", id: false, force: :cascade do |t|
    t.integer "donation_id"
    t.integer "payment_import_id"
  end

  create_table "drip_email_lists", id: :serial, force: :cascade do |t|
    t.string "mailchimp_list_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "email_customizations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "contents"
    t.integer "nonprofit_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_email_customizations_on_name"
    t.index ["nonprofit_id"], name: "index_email_customizations_on_nonprofit_id"
  end

  create_table "email_lists", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id", null: false
    t.integer "tag_master_id", null: false
    t.string "list_name", limit: 255, null: false
    t.string "mailchimp_list_id", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "email_settings", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.boolean "notify_payments"
    t.boolean "notify_campaigns"
    t.boolean "notify_events"
    t.boolean "notify_payouts"
    t.boolean "notify_recurring_donations"
  end

  create_table "event_discounts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.integer "event_id"
    t.integer "percent"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "tagline", limit: 255
    t.text "summary"
    t.text "body"
    t.float "latitude"
    t.float "longitude"
    t.string "location", limit: 255
    t.string "main_image", limit: 255
    t.string "background_image", limit: 255
    t.integer "nonprofit_id"
    t.boolean "published"
    t.string "slug", limit: 255
    t.integer "total_raised"
    t.text "directions"
    t.string "venue_name", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "profile_id"
    t.string "city", limit: 255
    t.string "state_code", limit: 255
    t.string "address", limit: 255
    t.string "zip_code", limit: 255
    t.boolean "show_total_raised", default: false
    t.boolean "show_total_count", default: false
    t.boolean "hide_activity_feed"
    t.boolean "hide_title"
    t.boolean "deleted", default: false
    t.text "receipt_message"
    t.string "organizer_email", limit: 255
    t.datetime "start_datetime", precision: nil
    t.datetime "end_datetime", precision: nil
    t.index ["nonprofit_id", "deleted", "published", "end_datetime"], name: "events_nonprofit_id_not_deleted_and_published_endtime"
    t.index ["nonprofit_id", "deleted", "published"], name: "index_events_on_nonprofit_id_and_deleted_and_published"
    t.index ["nonprofit_id"], name: "index_events_on_nonprofit_id"
  end

  create_table "export_formats", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "date_format"
    t.boolean "show_currency", default: true, null: false
    t.jsonb "custom_columns_and_values"
    t.integer "nonprofit_id", null: false
    t.index ["nonprofit_id"], name: "index_export_formats_on_nonprofit_id"
  end

  create_table "exports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.string "status", limit: 255
    t.text "exception"
    t.datetime "ended", precision: nil
    t.string "export_type", limit: 255
    t.text "parameters"
    t.string "url", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["nonprofit_id"], name: "index_exports_on_nonprofit_id"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "fee_coverage_detail_bases", id: :serial, force: :cascade do |t|
    t.integer "flat_fee"
    t.decimal "percentage_fee"
    t.boolean "dont_consider_billing_plan", default: false, null: false
    t.integer "fee_era_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["fee_era_id"], name: "index_fee_coverage_detail_bases_on_fee_era_id"
  end

  create_table "fee_eras", id: :serial, force: :cascade do |t|
    t.datetime "start_time", precision: nil
    t.datetime "end_time", precision: nil
    t.string "local_country"
    t.decimal "international_surcharge_fee"
    t.boolean "refund_stripe_fee", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "fee_structures", id: :serial, force: :cascade do |t|
    t.string "brand"
    t.integer "flat_fee"
    t.decimal "stripe_fee"
    t.integer "fee_era_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["fee_era_id"], name: "index_fee_structures_on_fee_era_id"
  end

  create_table "full_contact_infos", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "full_name", limit: 255
    t.string "gender", limit: 255
    t.string "city", limit: 255
    t.string "county", limit: 255
    t.string "state_code", limit: 255
    t.string "country", limit: 255
    t.string "continent", limit: 255
    t.string "age", limit: 255
    t.string "age_range", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "supporter_id"
    t.string "location_general", limit: 255
    t.text "websites"
    t.index ["supporter_id"], name: "index_full_contact_infos_on_supporter_id"
  end

  create_table "full_contact_jobs", force: :cascade do |t|
    t.integer "supporter_id"
  end

  create_table "full_contact_orgs", id: :serial, force: :cascade do |t|
    t.boolean "is_primary"
    t.string "name", limit: 255
    t.date "start_date"
    t.date "end_date"
    t.string "title", limit: 255
    t.boolean "current"
    t.integer "full_contact_info_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["full_contact_info_id"], name: "index_full_contact_orgs_on_full_contact_info_id"
  end

  create_table "full_contact_photos", id: :serial, force: :cascade do |t|
    t.integer "full_contact_info_id"
    t.string "type_id", limit: 255
    t.boolean "is_primary"
    t.text "url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["full_contact_info_id", "is_primary"], name: "index_full_context_photo_info_primary"
  end

  create_table "full_contact_social_profiles", id: :serial, force: :cascade do |t|
    t.integer "full_contact_info_id"
    t.string "type_id", limit: 255
    t.string "username", limit: 255
    t.string "uid", limit: 255
    t.text "bio"
    t.string "url", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "followers"
    t.integer "following"
    t.index ["full_contact_info_id"], name: "index_full_contact_social_profiles_on_full_contact_info_id"
  end

  create_table "full_contact_topics", id: :serial, force: :cascade do |t|
    t.string "provider", limit: 255
    t.string "value", limit: 255
    t.integer "full_contact_info_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["full_contact_info_id"], name: "index_full_contact_topics_on_full_contact_info_id"
  end

  create_table "image_attachments", id: :serial, force: :cascade do |t|
    t.string "file", limit: 255
    t.integer "parent_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "parent_type", limit: 255
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.integer "row_count"
    t.datetime "date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "imported_count"
    t.integer "nonprofit_id"
    t.integer "user_id"
  end

  create_table "manual_balance_adjustments", id: :serial, force: :cascade do |t|
    t.integer "gross_amount", default: 0
    t.integer "fee_total", default: 0
    t.integer "net_amount", default: 0
    t.integer "payment_id"
    t.integer "entity_id"
    t.string "entity_type"
    t.text "staff_comment"
    t.boolean "disbursed", default: false
    t.jsonb "metadata"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "misc_campaign_infos", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "campaign_id"
    t.boolean "manual_cover_fees"
    t.boolean "hide_cover_fees_option"
    t.boolean "paused", default: false, null: false
    t.string "fee_coverage_option_config"
    t.index ["campaign_id"], name: "index_misc_campaign_infos_on_campaign_id"
  end

  create_table "misc_event_infos", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.boolean "hide_cover_fees_option"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "custom_get_tickets_button_label"
    t.string "fee_coverage_option_config"
  end

  create_table "misc_payment_infos", id: :serial, force: :cascade do |t|
    t.integer "payment_id"
    t.boolean "fee_covered"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["payment_id"], name: "index_misc_payment_infos_on_payment_id"
  end

  create_table "misc_recurring_donation_infos", id: :serial, force: :cascade do |t|
    t.integer "recurring_donation_id"
    t.boolean "fee_covered"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["recurring_donation_id"], name: "index_misc_recurring_donation_infos_on_recurring_donation_id"
  end

  create_table "misc_refund_infos", id: :serial, force: :cascade do |t|
    t.boolean "is_modern"
    t.string "stripe_application_fee_refund_id", limit: 255
    t.integer "refund_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "miscellaneous_np_infos", id: :serial, force: :cascade do |t|
    t.string "donate_again_url", limit: 255
    t.integer "nonprofit_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "change_amount_message"
    t.boolean "first_charge_email_sent"
    t.boolean "hide_cover_fees", default: false, null: false
    t.boolean "temp_block", default: false
    t.string "fee_coverage_option_config"
    t.index ["nonprofit_id"], name: "index_miscellaneous_np_infos_on_nonprofit_id"
  end

  create_table "modern_donations", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.integer "donation_id", null: false
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_modern_donations_on_houid", unique: true
  end

  create_table "nonprofit_deactivations", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id"
    t.boolean "deactivated"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "nonprofit_keys", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id"
    t.jsonb "mailchimp_token"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "nonprofit_s3_keys", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id"
    t.string "access_key_id"
    t.string "secret_access_key"
    t.string "bucket_name"
    t.string "region"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["nonprofit_id"], name: "index_nonprofit_s3_keys_on_nonprofit_id"
  end

  create_table "nonprofit_verification_backups", id: :serial, force: :cascade do |t|
    t.string "verification_status", limit: 255
  end

  create_table "nonprofit_verification_process_statuses", id: :serial, force: :cascade do |t|
    t.string "stripe_account_id", limit: 255, null: false
    t.datetime "started_at", precision: nil
    t.string "email_to_send_guid", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["stripe_account_id"], name: "index_nonprofit_verification_to_stripe", unique: true
  end

  create_table "nonprofits", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name", limit: 255
    t.string "tagline", limit: 255
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.string "main_image", limit: 255
    t.string "website", limit: 255
    t.string "background_image", limit: 255
    t.string "logo", limit: 255
    t.text "summary"
    t.text "categories_legacy"
    t.string "ein", limit: 255
    t.text "full_description"
    t.text "achievements_legacy"
    t.string "state_code", limit: 255
    t.string "city", limit: 255
    t.string "slug", limit: 255
    t.boolean "published"
    t.text "address"
    t.boolean "vetted"
    t.string "zip_code", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "state_code_slug", limit: 255
    t.string "city_slug", limit: 255
    t.string "referrer", limit: 255
    t.text "thank_you_note"
    t.boolean "no_anon"
    t.string "timezone", limit: 255
    t.string "statement", limit: 255
    t.string "brand_color", limit: 255
    t.string "brand_font", limit: 255
    t.string "stripe_account_id", limit: 255
    t.boolean "hide_activity_feed"
    t.text "tracking_script", default: ""
    t.string "facebook", limit: 255
    t.string "twitter", limit: 255
    t.string "youtube", limit: 255
    t.string "instagram", limit: 255
    t.string "blog", limit: 255
    t.text "card_failure_message_top"
    t.text "card_failure_message_bottom"
    t.text "fields_needed"
    t.boolean "autocomplete_supporter_address", default: false
    t.string "currency", limit: 255, default: "usd"
    t.boolean "feature_flag_autocomplete_supporter_address", default: false
    t.string "houid"
    t.jsonb "achievements"
    t.jsonb "categories"
    t.boolean "hide_main_image", default: false, null: false
    t.boolean "require_two_factor", default: false, null: false
  end

  create_table "object_events", id: :serial, force: :cascade do |t|
    t.integer "event_entity_id"
    t.string "event_entity_type"
    t.string "event_type"
    t.string "event_entity_houid"
    t.integer "nonprofit_id"
    t.string "houid"
    t.datetime "created", precision: nil
    t.jsonb "object_json"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_entity_houid"], name: "index_object_events_on_event_entity_houid"
    t.index ["event_entity_type", "event_entity_id"], name: "index_object_events_on_event_entity_type_and_event_entity_id"
    t.index ["event_entity_type"], name: "index_object_events_on_event_entity_type"
    t.index ["event_type"], name: "index_object_events_on_event_type"
    t.index ["houid"], name: "index_object_events_on_houid"
    t.index ["nonprofit_id"], name: "index_object_events_on_nonprofit_id"
  end

  create_table "offline_transaction_charges", id: :serial, force: :cascade do |t|
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_offline_transaction_charges_on_houid", unique: true
  end

  create_table "offline_transactions", id: :serial, force: :cascade do |t|
    t.integer "amount", null: false
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_offline_transactions_on_houid", unique: true
  end

  create_table "offsite_payments", id: :serial, force: :cascade do |t|
    t.integer "gross_amount"
    t.string "kind", limit: 255
    t.integer "nonprofit_id"
    t.integer "supporter_id"
    t.integer "donation_id"
    t.integer "payment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "date", precision: nil
    t.string "check_number", limit: 255
    t.integer "user_id"
    t.index ["check_number"], name: "index_offsite_payments_on_check_number"
    t.index ["payment_id"], name: "index_offsite_payments_on_payment_id"
    t.index ["supporter_id"], name: "index_offsite_payments_on_supporter_id"
  end

  create_table "payment_imports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "payment_payouts", id: :serial, force: :cascade do |t|
    t.integer "donation_id"
    t.integer "payout_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "total_fees"
    t.integer "charge_id"
    t.integer "payment_id"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "gross_amount"
    t.integer "refund_total", default: 0
    t.integer "fee_total"
    t.integer "net_amount"
    t.integer "nonprofit_id"
    t.integer "supporter_id"
    t.string "towards", limit: 255
    t.string "kind", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "donation_id"
    t.datetime "date", precision: nil
    t.index ["date"], name: "payments_date"
    t.index ["donation_id"], name: "payments_donation_id"
    t.index ["gross_amount"], name: "payments_gross_amount"
    t.index ["kind"], name: "payments_kind"
    t.index ["nonprofit_id"], name: "payments_nonprofit_id"
    t.index ["supporter_id"], name: "payments_supporter_id"
  end

  create_table "payouts", id: :serial, force: :cascade do |t|
    t.integer "net_amount"
    t.integer "nonprofit_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "failure_message", limit: 255
    t.string "status", limit: 255
    t.integer "fee_total"
    t.integer "gross_amount"
    t.string "bank_name", limit: 255
    t.string "email", limit: 255
    t.integer "count"
    t.boolean "manual"
    t.boolean "scheduled"
    t.string "stripe_transfer_id", limit: 255
    t.string "user_ip", limit: 255
    t.integer "ach_fee"
    t.string "houid"
    t.index ["houid"], name: "index_payouts_on_houid", unique: true
  end

  create_table "periodic_reports", id: :serial, force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.string "report_type", null: false
    t.string "period", null: false
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.string "filename"
    t.integer "nonprofit_s3_key_id"
    t.index ["nonprofit_id"], name: "index_periodic_reports_on_nonprofit_id"
    t.index ["user_id"], name: "index_periodic_reports_on_user_id"
  end

  create_table "periodic_reports_users", id: :serial, force: :cascade do |t|
    t.integer "periodic_report_id"
    t.integer "user_id"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.integer "admin_id"
    t.string "state_code", limit: 255
    t.string "city", limit: 255
    t.string "picture", limit: 255
    t.string "phone", limit: 255
    t.string "address", limit: 255
    t.boolean "anonymous"
    t.string "zip_code", limit: 255
    t.integer "total_recurring"
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.text "mini_bio"
    t.string "country", limit: 255, default: "US"
  end

  create_table "recaptcha_rejections", id: :serial, force: :cascade do |t|
    t.jsonb "details"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "recurring_donation_holds", id: :serial, force: :cascade do |t|
    t.integer "recurring_donation_id"
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "recurring_donations", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "paydate"
    t.integer "card_id"
    t.integer "nonprofit_id"
    t.integer "campaign_id"
    t.string "origin_url", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "profile_id"
    t.integer "amount"
    t.integer "supporter_id"
    t.string "email", limit: 255
    t.string "edit_token", limit: 255
    t.string "failure_message", limit: 255
    t.integer "interval"
    t.string "time_unit", limit: 255
    t.date "start_date"
    t.date "end_date"
    t.boolean "anonymous", default: false, null: false
    t.integer "donation_id"
    t.integer "n_failures"
    t.string "cancelled_by", limit: 255
    t.datetime "cancelled_at", precision: nil
    t.index ["donation_id"], name: "index_recurring_donations_on_donation_id"
    t.index ["supporter_id"], name: "index_recurring_donations_on_supporter_id"
  end

  create_table "refunds", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.text "comment"
    t.integer "charge_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "stripe_refund_id", limit: 255
    t.string "reason", limit: 255
    t.boolean "disbursed"
    t.integer "user_id"
    t.integer "payment_id"
    t.index ["charge_id"], name: "index_refunds_on_charge_id"
    t.index ["payment_id"], name: "index_refunds_on_payment_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "user_id"
    t.integer "host_id"
    t.string "host_type", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "user_id", "host_id"], name: "index_roles_on_name_and_user_id_and_host_id"
  end

  create_table "simple_objects", id: :serial, force: :cascade do |t|
    t.string "houid"
    t.integer "parent_id"
    t.integer "friend_id"
    t.integer "nonprofit_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "source_tokens", id: false, force: :cascade do |t|
    t.uuid "token", null: false
    t.datetime "expiration", precision: nil
    t.integer "tokenizable_id"
    t.string "tokenizable_type", limit: 255
    t.integer "event_id"
    t.integer "max_uses", default: 1
    t.integer "total_uses", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["expiration"], name: "index_source_tokens_on_expiration"
    t.index ["token"], name: "index_source_tokens_on_token", unique: true
    t.index ["tokenizable_id", "tokenizable_type"], name: "index_source_tokens_on_tokenizable_id_and_tokenizable_type"
  end

  create_table "stripe_accounts", id: :serial, force: :cascade do |t|
    t.string "stripe_account_id", limit: 255, null: false
    t.jsonb "object", null: false
    t.boolean "charges_enabled"
    t.boolean "payouts_enabled"
    t.string "disabled_reason", limit: 255
    t.jsonb "eventually_due"
    t.jsonb "currently_due"
    t.jsonb "past_due"
    t.jsonb "pending_verification"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["id"], name: "index_stripe_accounts_on_id"
    t.index ["stripe_account_id"], name: "index_stripe_accounts_on_stripe_account_id"
  end

  create_table "stripe_charges", id: :serial, force: :cascade do |t|
    t.jsonb "object", null: false
    t.string "stripe_charge_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["stripe_charge_id"], name: "index_stripe_charges_on_stripe_charge_id"
  end

  create_table "stripe_disputes", id: :serial, force: :cascade do |t|
    t.jsonb "object"
    t.jsonb "balance_transactions"
    t.string "stripe_dispute_id", limit: 255
    t.string "stripe_charge_id", limit: 255
    t.string "status", limit: 255
    t.string "reason", limit: 255
    t.integer "net_change"
    t.integer "amount"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "evidence_due_date", precision: nil
    t.datetime "started_at", precision: nil
    t.index ["id"], name: "index_stripe_disputes_on_id"
    t.index ["stripe_charge_id"], name: "index_stripe_disputes_on_stripe_charge_id"
    t.index ["stripe_dispute_id"], name: "index_stripe_disputes_on_stripe_dispute_id", unique: true
  end

  create_table "stripe_events", id: :serial, force: :cascade do |t|
    t.string "object_id", limit: 255
    t.string "event_id", limit: 255
    t.datetime "event_time", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_stripe_events_on_event_id"
    t.index ["object_id", "event_time"], name: "index_stripe_events_on_object_id_and_event_time"
  end

  create_table "stripe_transaction_charges", id: :serial, force: :cascade do |t|
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_stripe_transaction_charges_on_houid"
  end

  create_table "stripe_transaction_dispute_reversals", id: :serial, force: :cascade do |t|
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_stripe_transaction_dispute_reversals_on_houid"
  end

  create_table "stripe_transaction_disputes", id: :serial, force: :cascade do |t|
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_stripe_transaction_disputes_on_houid"
  end

  create_table "stripe_transaction_refunds", id: :serial, force: :cascade do |t|
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_stripe_transaction_refunds_on_houid"
  end

  create_table "stripe_transactions", id: :serial, force: :cascade do |t|
    t.integer "amount", null: false
    t.string "houid", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["houid"], name: "index_stripe_transactions_on_houid"
  end

  create_table "subtransaction_payments", id: :serial, force: :cascade do |t|
    t.integer "subtransaction_id", null: false
    t.integer "paymentable_id", null: false
    t.string "paymentable_type", null: false
    t.datetime "created", precision: nil
    t.integer "legacy_payment_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["legacy_payment_id"], name: "index_subtransaction_payments_on_legacy_payment_id", unique: true
    t.index ["paymentable_type", "paymentable_id"], name: "idx_subtrxpayments_on_subtransactable_polymorphic", unique: true
  end

  create_table "subtransactions", id: :serial, force: :cascade do |t|
    t.integer "transaction_id", null: false
    t.integer "subtransactable_id", null: false
    t.string "subtransactable_type", null: false
    t.datetime "created", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["subtransactable_type", "subtransactable_id"], name: "idx_subtrx_on_subtransactable_polymorphic", unique: true
  end

  create_table "supporter_addresses", id: :serial, force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "zip_code"
    t.string "state_code"
    t.string "country"
    t.boolean "deleted", default: false, null: false
    t.integer "supporter_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["supporter_id"], name: "index_supporter_addresses_on_supporter_id"
  end

  create_table "supporter_emails", id: :serial, force: :cascade do |t|
    t.text "to"
    t.string "from", limit: 255
    t.string "subject", limit: 255
    t.text "body"
    t.integer "supporter_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "nonprofit_id"
    t.integer "recipient_count"
    t.integer "user_id"
    t.string "gmail_thread_id", limit: 255
  end

  create_table "supporter_notes", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "supporter_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.boolean "deleted", default: false
    t.index ["supporter_id"], name: "index_supporter_notes_on_supporter_id"
  end

  create_table "supporters", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "nonprofit_id"
    t.text "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.string "phone", limit: 255
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.string "state_code", limit: 255
    t.boolean "anonymous", default: false, null: false
    t.string "zip_code", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.integer "full_contact_info_id"
    t.boolean "deleted", default: false
    t.string "organization", limit: 255
    t.datetime "imported_at", precision: nil
    t.string "country", limit: 255, default: "United States"
    t.integer "import_id"
    t.boolean "is_unsubscribed_from_emails"
    t.integer "merged_into"
    t.datetime "merged_at", precision: nil
    t.string "region", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "locale", limit: 255
    t.tsvector "fts"
    t.string "phone_index"
    t.integer "primary_address_id"
    t.string "houid"
    t.index "lower((email)::text)", name: "supporters_email", where: "(deleted <> true)"
    t.index "lower((name)::text)", name: "supporters_lower_name", where: "(deleted <> true)"
    t.index "to_tsvector('english'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || (COALESCE(email, ''::character varying))::text))", name: "supporters_general_idx", using: :gin
    t.index ["anonymous", "nonprofit_id"], name: "index_supporters_on_anonymous_and_nonprofit_id"
    t.index ["fts"], name: "supporters_fts_idx", using: :gin
    t.index ["name"], name: "index_supporters_on_name"
    t.index ["nonprofit_id", "deleted"], name: "supporters_nonprofit_id_not_deleted", where: "(NOT deleted)"
    t.index ["nonprofit_id", "imported_at"], name: "index_supporters_on_nonprofit_id_and_imported_at"
    t.index ["nonprofit_id", "phone_index", "deleted"], name: "index_supporters_on_nonprofit_id_and_phone_index_and_deleted", where: "((phone IS NOT NULL) AND ((phone)::text <> ''::text))"
    t.index ["nonprofit_id"], name: "supporters_nonprofit_id", where: "(deleted <> true)"
  end

  create_table "tag_joins", id: :serial, force: :cascade do |t|
    t.integer "tag_master_id"
    t.integer "supporter_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["supporter_id"], name: "tag_joins_supporter_id"
    t.index ["tag_master_id", "supporter_id"], name: "tag_join_supporter_unique_idx", unique: true
    t.index ["tag_master_id"], name: "index_tag_joins_on_tag_master_id"
    t.index ["tag_master_id"], name: "tag_joins_tag_master_id"
  end

  create_table "tag_masters", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "nonprofit_id"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["nonprofit_id", "deleted"], name: "tag_masters_nonprofit_id_not_deleted", where: "(NOT deleted)"
  end

  create_table "ticket_levels", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "amount"
    t.integer "quantity"
    t.string "name", limit: 255
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "deleted", default: false
    t.integer "limit"
    t.integer "event_discount_id"
    t.boolean "admin_only"
    t.integer "order"
  end

  create_table "ticket_purchases", id: :serial, force: :cascade do |t|
    t.string "houid", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tickets", id: :serial, force: :cascade do |t|
    t.integer "ticket_level_id"
    t.integer "charge_id"
    t.integer "profile_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "supporter_id"
    t.integer "event_id"
    t.integer "quantity"
    t.boolean "checked_in"
    t.integer "bid_id"
    t.integer "card_id"
    t.integer "payment_id"
    t.text "note"
    t.integer "event_discount_id"
    t.boolean "deleted", default: false
    t.uuid "source_token_id"
    t.integer "ticket_purchase_id"
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["payment_id"], name: "index_tickets_on_payment_id"
    t.index ["supporter_id"], name: "index_tickets_on_supporter_id"
    t.index ["ticket_purchase_id"], name: "index_tickets_on_ticket_purchase_id"
  end

  create_table "trackings", id: :serial, force: :cascade do |t|
    t.string "utm_campaign", limit: 255
    t.string "utm_medium", limit: 255
    t.string "utm_source", limit: 255
    t.integer "donation_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "utm_content", limit: 255
  end

  create_table "transaction_assignments", id: :serial, force: :cascade do |t|
    t.integer "transaction_id", null: false
    t.integer "assignable_id", null: false
    t.string "assignable_type", null: false
    t.index ["assignable_type", "assignable_id"], name: "idx_trx_assignments_assignable_polymorphic", unique: true
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.integer "supporter_id"
    t.string "houid", null: false
    t.integer "amount"
    t.datetime "created", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["created"], name: "index_transactions_on_created"
    t.index ["houid"], name: "index_transactions_on_houid", unique: true
    t.index ["supporter_id"], name: "index_transactions_on_supporter_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.integer "user_id"
    t.string "token", limit: 255
    t.string "secret", limit: 255
    t.string "link", limit: 255
    t.string "name", limit: 255
    t.boolean "auto_generated"
    t.integer "referer"
    t.boolean "pending_password"
    t.string "picture", limit: 255
    t.string "city", limit: 255
    t.string "state_code", limit: 255
    t.string "location", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email", limit: 255
    t.string "phone"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.string "otp_secret"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "widget_descriptions", id: :serial, force: :cascade do |t|
    t.string "houid", null: false
    t.string "custom_recurring_donation_phrase"
    t.jsonb "custom_amounts"
    t.jsonb "postfix_element"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["houid"], name: "index_widget_descriptions_on_houid", unique: true
  end

  add_foreign_key "campaign_gifts", "campaign_gift_options", name: "campaign_gifts_to_option_fk"
  add_foreign_key "email_customizations", "nonprofits"
  add_foreign_key "export_formats", "nonprofits"
  add_foreign_key "fee_coverage_detail_bases", "fee_eras"
  add_foreign_key "fee_structures", "fee_eras"
  add_foreign_key "payments", "supporters", name: "payments_supporter_fk"
  add_foreign_key "periodic_reports", "nonprofits"
  add_foreign_key "periodic_reports", "users"
  add_foreign_key "supporter_addresses", "supporters"
  create_function :is_valid_json, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.is_valid_json(p_json text)
       RETURNS boolean
       LANGUAGE plpgsql
       IMMUTABLE
      AS $function$
      begin
        return (p_json::json is not null);
      exception
        when others then
           return false;
      end;
      $function$
  SQL
  create_function :update_fts_on_donations, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.update_fts_on_donations()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
              BEGIN
                new.fts = to_tsvector('english', coalesce(new.comment, ''));
                RETURN new;
              END
            $function$
  SQL
  create_function :update_fts_on_supporters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.update_fts_on_supporters()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
              BEGIN
                new.fts = to_tsvector('english', coalesce(new.name, '') || ' ' || coalesce(new.email, '') || ' ' || coalesce(new.organization, ''));
                RETURN new;
              END
            $function$
  SQL
  create_function :update_phone_index_on_supporters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.update_phone_index_on_supporters()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
                  BEGIN
                    new.phone_index = (regexp_replace(new.phone, '\D','', 'g'));
                    RETURN new;
                  END
                $function$
  SQL


  create_trigger :update_donations_fts, sql_definition: <<-SQL
      CREATE TRIGGER update_donations_fts BEFORE INSERT OR UPDATE ON public.donations FOR EACH ROW EXECUTE FUNCTION update_fts_on_donations()
  SQL
  create_trigger :update_supporters_phone_index, sql_definition: <<-SQL
      CREATE TRIGGER update_supporters_phone_index BEFORE INSERT OR UPDATE ON public.supporters FOR EACH ROW EXECUTE FUNCTION update_phone_index_on_supporters()
  SQL
  create_trigger :update_supporters_fts, sql_definition: <<-SQL
      CREATE TRIGGER update_supporters_fts BEFORE INSERT OR UPDATE ON public.supporters FOR EACH ROW EXECUTE FUNCTION update_fts_on_supporters()
  SQL
end
