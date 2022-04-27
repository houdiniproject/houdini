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

ActiveRecord::Schema.define(version: 2022_04_27_052420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "supporter_id"
    t.integer "host_id"
    t.string "host_type", limit: 255
    t.string "action_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attachment_id"
    t.string "attachment_type", limit: 255
    t.integer "nonprofit_id"
    t.boolean "public"
    t.integer "user_id"
    t.datetime "date"
    t.string "kind", limit: 255
    t.text "json_data"
    t.index ["nonprofit_id"], name: "index_activities_on_nonprofit_id"
    t.index ["supporter_id"], name: "index_activities_on_supporter_id"
  end

  create_table "bank_accounts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "account_number", limit: 255
    t.string "bank_name", limit: 255
    t.string "email", limit: 255
    t.integer "nonprofit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pending_verification"
    t.string "confirmation_token", limit: 255
    t.string "status", limit: 255
    t.string "stripe_bank_account_token", limit: 255
    t.string "stripe_bank_account_id", limit: 255
    t.boolean "deleted"
  end

  create_table "billing_plans", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "stripe_plan_id", limit: 255
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "interval", limit: 255
    t.float "percentage_fee", default: 0.0, null: false
  end

  create_table "billing_subscriptions", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id"
    t.integer "billing_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", limit: 255
  end

  create_table "campaign_gift_options", id: :serial, force: :cascade do |t|
    t.integer "amount_one_time"
    t.text "description"
    t.string "name", limit: 255
    t.integer "campaign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "amount_dollars", limit: 255
    t.integer "amount_recurring"
    t.integer "quantity"
    t.boolean "to_ship", default: false, null: false
    t.integer "order"
    t.boolean "hide_contributions", default: false, null: false
  end

  create_table "campaign_gift_purchases", id: :string, force: :cascade do |t|
    t.boolean "deleted", default: false, null: false
    t.integer "amount", null: false
    t.bigint "campaign_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_campaign_gift_purchases_on_campaign_id"
  end

  create_table "campaign_gifts", id: :serial, force: :cascade do |t|
    t.integer "donation_id"
    t.integer "campaign_gift_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published"
    t.string "background_image", limit: 255
    t.integer "total_supporters"
    t.boolean "recurring_fund"
    t.string "slug", limit: 255
    t.string "youtube_video_id", limit: 255
    t.string "tagline", limit: 255
    t.text "video_url"
    t.boolean "show_total_raised", default: true
    t.boolean "show_total_count", default: true
    t.boolean "hide_activity_feed"
    t.boolean "deleted"
    t.boolean "hide_title"
    t.boolean "hide_thermometer"
    t.boolean "hide_goal"
    t.text "receipt_message"
    t.boolean "hide_custom_amounts"
    t.boolean "show_recurring_amount", default: false
    t.datetime "end_datetime"
    t.string "external_identifier", limit: 255
    t.integer "parent_campaign_id"
    t.text "reason_for_supporting"
    t.text "default_reason_for_supporting"
    t.string "banner_image", limit: 255
    t.index ["parent_campaign_id"], name: "index_campaigns_on_parent_campaign_id"
  end

  create_table "cards", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "deleted"
    t.boolean "inactive"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_id"
    t.string "status", limit: 255
    t.integer "fee"
    t.integer "direct_debit_detail_id"
    t.index ["payment_id"], name: "index_charges_on_payment_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "host_id"
    t.string "host_type", limit: 255
  end

  create_table "custom_field_definitions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "nonprofit_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_field_joins", id: :serial, force: :cascade do |t|
    t.integer "custom_field_definition_id"
    t.integer "supporter_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_definition_id", "supporter_id"], name: "custom_field_join_supporter_unique_idx", unique: true
    t.index ["custom_field_definition_id"], name: "custom_field_joins_custom_field_definition_id"
  end

  create_table "custom_field_joins_backup", id: :serial, force: :cascade do |t|
    t.integer "custom_field_definition_id"
    t.integer "supporter_id"
    t.text "metadata"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "direct_debit_details", id: :serial, force: :cascade do |t|
    t.string "iban", limit: 255
    t.string "account_holder_name", limit: 255
    t.string "bic", limit: 255
    t.integer "holder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disputes", id: :serial, force: :cascade do |t|
    t.integer "gross_amount"
    t.integer "charge_id"
    t.integer "payment_id"
    t.string "reason", limit: 255
    t.string "status", limit: 255
    t.string "stripe_dispute_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "donations", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.integer "profile_id"
    t.integer "nonprofit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "card_id"
    t.text "designation"
    t.boolean "offsite"
    t.boolean "anonymous"
    t.integer "supporter_id"
    t.text "origin_url"
    t.boolean "manual"
    t.integer "campaign_id"
    t.integer "recurring_donation_id"
    t.text "comment"
    t.boolean "recurring"
    t.jsonb "dedication"
    t.integer "event_id"
    t.datetime "imported_at"
    t.integer "charge_id"
    t.integer "payment_id"
    t.datetime "date"
    t.datetime "queued_for_import_at"
    t.integer "direct_debit_detail_id"
    t.string "payment_provider", limit: 255
    t.index "lower(designation)", name: "donations_designation"
    t.index ["amount"], name: "donations_amount"
    t.index ["campaign_id"], name: "donations_campaign_id"
    t.index ["event_id"], name: "donations_event_id"
    t.index ["event_id"], name: "index_donations_on_event_id"
    t.index ["supporter_id"], name: "donations_supporter_id"
  end

  create_table "donations_payment_imports", id: false, force: :cascade do |t|
    t.integer "donation_id"
    t.integer "payment_import_id"
  end

  create_table "email_lists", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id", null: false
    t.integer "tag_definition_id", null: false
    t.string "list_name", limit: 255, null: false
    t.string "mailchimp_list_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "tagline", limit: 255
    t.text "summary"
    t.text "body"
    t.string "location", limit: 255
    t.string "main_image", limit: 255
    t.string "background_image", limit: 255
    t.integer "nonprofit_id"
    t.boolean "published"
    t.string "slug", limit: 255
    t.integer "total_raised"
    t.text "directions"
    t.string "venue_name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profile_id"
    t.string "city", limit: 255
    t.string "state_code", limit: 255
    t.string "address", limit: 255
    t.string "zip_code", limit: 255
    t.boolean "show_total_raised", default: false
    t.boolean "show_total_count", default: false
    t.boolean "hide_activity_feed"
    t.boolean "hide_title"
    t.boolean "deleted"
    t.text "receipt_message"
    t.string "organizer_email", limit: 255
    t.datetime "start_datetime"
    t.datetime "end_datetime"
  end

  create_table "exports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.string "status", limit: 255
    t.text "exception"
    t.datetime "ended"
    t.string "export_type", limit: 255
    t.text "parameters"
    t.string "url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nonprofit_id"], name: "index_exports_on_nonprofit_id"
    t.index ["user_id"], name: "index_exports_on_user_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "supporter_id"
    t.string "location_general", limit: 255
    t.text "websites"
  end

  create_table "full_contact_jobs", id: :serial, force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "full_contact_photos", id: :serial, force: :cascade do |t|
    t.integer "full_contact_info_id"
    t.string "type_id", limit: 255
    t.boolean "is_primary"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "full_contact_social_profiles", id: :serial, force: :cascade do |t|
    t.integer "full_contact_info_id"
    t.string "type_id", limit: 255
    t.string "username", limit: 255
    t.string "uid", limit: 255
    t.text "bio"
    t.string "url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "followers"
    t.integer "following"
  end

  create_table "full_contact_topics", id: :serial, force: :cascade do |t|
    t.string "provider", limit: 255
    t.string "value", limit: 255
    t.integer "full_contact_info_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "image_attachments", id: :serial, force: :cascade do |t|
    t.string "file", limit: 255
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "parent_type", limit: 255
  end

  create_table "import_requests", force: :cascade do |t|
    t.jsonb "header_matches"
    t.bigint "nonprofit_id"
    t.string "user_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nonprofit_id"], name: "index_import_requests_on_nonprofit_id"
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.integer "row_count"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "imported_count"
    t.integer "nonprofit_id"
    t.integer "user_id"
  end

  create_table "miscellaneous_np_infos", id: :serial, force: :cascade do |t|
    t.string "donate_again_url", limit: 255
    t.integer "nonprofit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "change_amount_message"
  end

  create_table "modern_campaign_gifts", id: :string, force: :cascade do |t|
    t.boolean "deleted", default: false, null: false
    t.bigint "campaign_gift_id", null: false
    t.integer "amount", default: 0, null: false
    t.string "campaign_gift_purchase_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_gift_id"], name: "index_modern_campaign_gifts_on_campaign_gift_id"
    t.index ["campaign_gift_purchase_id"], name: "index_modern_campaign_gifts_on_campaign_gift_purchase_id"
  end

  create_table "modern_donations", id: :string, force: :cascade do |t|
    t.integer "amount"
    t.bigint "donation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["donation_id"], name: "index_modern_donations_on_donation_id"
  end

  create_table "nonprofit_keys", id: :serial, force: :cascade do |t|
    t.integer "nonprofit_id"
    t.text "mailchimp_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nonprofits", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 255
    t.string "tagline", limit: 255
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.string "main_image", limit: 255
    t.string "second_image", limit: 255
    t.string "third_image", limit: 255
    t.string "website", limit: 255
    t.string "background_image", limit: 255
    t.string "logo", limit: 255
    t.text "summary"
    t.text "categories"
    t.string "ein", limit: 255
    t.text "full_description"
    t.text "achievements"
    t.string "state_code", limit: 255
    t.string "city", limit: 255
    t.string "slug", limit: 255
    t.boolean "published"
    t.text "address"
    t.boolean "vetted"
    t.string "zip_code", limit: 255
    t.integer "pending_balance"
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
    t.string "verification_status", limit: 255
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
  end

  create_table "object_event_hook_configs", force: :cascade do |t|
    t.string "webhook_service", null: false
    t.jsonb "configuration", null: false
    t.bigint "nonprofit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "object_event_types", default: [], null: false
    t.index ["nonprofit_id"], name: "index_object_event_hook_configs_on_nonprofit_id"
  end

  create_table "offline_transaction_charges", id: :string, force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_offline_transaction_charges_on_payment_id"
  end

  create_table "offline_transaction_disputes", id: :string, force: :cascade do |t|
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_offline_transaction_disputes_on_payment_id"
  end

  create_table "offline_transaction_refunds", id: :string, force: :cascade do |t|
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_offline_transaction_refunds_on_payment_id"
  end

  create_table "offline_transactions", id: :string, force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "offsite_payments", id: :serial, force: :cascade do |t|
    t.integer "gross_amount"
    t.string "kind", limit: 255
    t.integer "nonprofit_id"
    t.integer "supporter_id"
    t.integer "donation_id"
    t.integer "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
    t.string "check_number", limit: 255
    t.integer "user_id"
  end

  create_table "payment_imports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_payouts", id: :serial, force: :cascade do |t|
    t.integer "donation_id"
    t.integer "payout_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_fees"
    t.integer "charge_id"
    t.integer "payment_id"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "gross_amount"
    t.integer "refund_total"
    t.integer "fee_total"
    t.integer "net_amount"
    t.integer "nonprofit_id"
    t.integer "supporter_id"
    t.string "towards", limit: 255
    t.string "kind", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "donation_id"
    t.datetime "date"
    t.tsvector "search_vectors"
    t.index "lower((towards)::text)", name: "payments_towards"
    t.index ["created_at"], name: "index_payments_on_created_at"
    t.index ["date"], name: "payments_date"
    t.index ["donation_id"], name: "payments_donation_id"
    t.index ["gross_amount"], name: "payments_gross_amount"
    t.index ["kind"], name: "payments_kind"
    t.index ["nonprofit_id"], name: "payments_nonprofit_id"
    t.index ["search_vectors"], name: "payments_search_idx", using: :gin
    t.index ["supporter_id"], name: "payments_supporter_id"
  end

  create_table "payouts", id: :serial, force: :cascade do |t|
    t.integer "net_amount"
    t.integer "nonprofit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "admin_id"
    t.string "state_code", limit: 255
    t.string "city", limit: 255
    t.text "privacy_settings"
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

  create_table "recurrences", id: :string, force: :cascade do |t|
    t.integer "amount", null: false
    t.bigint "recurring_donation_id", null: false
    t.bigint "supporter_id", null: false
    t.datetime "start_date", comment: "the moment that the recurrence should start. Could be earlier than created_at if this was imported."
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["recurring_donation_id"], name: "index_recurrences_on_recurring_donation_id"
    t.index ["supporter_id"], name: "index_recurrences_on_supporter_id"
  end

  create_table "recurring_donations", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "paydate"
    t.integer "card_id"
    t.integer "nonprofit_id"
    t.integer "campaign_id"
    t.string "origin_url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "anonymous"
    t.integer "donation_id"
    t.integer "n_failures"
    t.string "cancelled_by", limit: 255
    t.datetime "cancelled_at"
    t.index ["donation_id"], name: "index_recurring_donations_on_donation_id"
  end

  create_table "refunds", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.text "comment"
    t.integer "charge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "source_tokens", id: false, force: :cascade do |t|
    t.uuid "token", null: false
    t.datetime "expiration"
    t.integer "tokenizable_id"
    t.string "tokenizable_type", limit: 255
    t.integer "event_id"
    t.integer "max_uses", default: 1
    t.integer "total_uses", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expiration"], name: "index_source_tokens_on_expiration"
    t.index ["token"], name: "index_source_tokens_on_token", unique: true
    t.index ["tokenizable_id", "tokenizable_type"], name: "index_source_tokens_on_tokenizable_id_and_tokenizable_type"
  end

  create_table "stripe_charges", id: :string, force: :cascade do |t|
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_stripe_charges_on_payment_id"
  end

  create_table "stripe_disputes", id: :string, force: :cascade do |t|
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_stripe_disputes_on_payment_id"
  end

  create_table "stripe_refunds", id: :string, force: :cascade do |t|
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_stripe_refunds_on_payment_id"
  end

  create_table "stripe_transactions", id: :string, force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subtransaction_payments", id: :string, force: :cascade do |t|
    t.string "subtransaction_id"
    t.string "paymentable_type"
    t.string "paymentable_id"
    t.datetime "created", comment: "the moment that the subtransaction_payment was created. Could be earlier than created_at if the transaction was in the past."
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["paymentable_type", "paymentable_id"], name: "index_subtransaction_payments_on_paymentable"
    t.index ["subtransaction_id"], name: "index_subtransaction_payments_on_subtransaction_id"
  end

  create_table "subtransactions", id: :string, force: :cascade do |t|
    t.string "transaction_id", null: false
    t.string "subtransactable_type", null: false
    t.string "subtransactable_id", null: false
    t.datetime "created", comment: "the moment that the subtransaction was created. Could be earlier than created_at if the transaction was in the past."
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subtransactable_type", "subtransactable_id"], name: "index_subtransactions_on_subtransactable", unique: true
    t.index ["transaction_id"], name: "index_subtransactions_on_transaction_id"
  end

  create_table "supporter_notes", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "supporter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "deleted", default: false, null: false
    t.index ["supporter_id"], name: "index_supporter_notes_on_supporter_id"
  end

  create_table "supporters", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "nonprofit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.string "phone", limit: 255
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.string "state_code", limit: 255
    t.boolean "anonymous", default: false, null: false
    t.string "zip_code", limit: 255
    t.integer "full_contact_info_id"
    t.boolean "deleted", default: false
    t.string "organization", limit: 255
    t.datetime "imported_at"
    t.string "country", limit: 255, default: "United States"
    t.integer "import_id"
    t.string "email_unsubscribe_uuid", limit: 255
    t.boolean "is_unsubscribed_from_emails"
    t.tsvector "search_vectors"
    t.integer "merged_into"
    t.datetime "merged_at"
    t.string "region", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "locale", limit: 255
    t.index "lower((email)::text)", name: "supporters_email", where: "(deleted <> true)"
    t.index "lower((name)::text)", name: "supporters_lower_name", where: "(deleted <> true)"
    t.index "to_tsvector('english'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || (COALESCE(email, ''::character varying))::text))", name: "supporters_general_idx", using: :gin
    t.index ["created_at"], name: "supporters_created_at", where: "(deleted <> true)"
    t.index ["deleted"], name: "index_supporters_on_deleted"
    t.index ["import_id"], name: "index_supporters_on_import_id"
    t.index ["name"], name: "index_supporters_on_name"
    t.index ["nonprofit_id"], name: "supporters_nonprofit_id", where: "(deleted <> true)"
    t.index ["search_vectors"], name: "supporters_search_idx", using: :gin
  end

  create_table "tag_definitions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "nonprofit_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tag_joins", id: :serial, force: :cascade do |t|
    t.integer "tag_definition_id"
    t.integer "supporter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supporter_id"], name: "tag_joins_supporter_id"
    t.index ["tag_definition_id", "supporter_id"], name: "index_tag_joins_on_tag_definition_id_and_supporter_id", unique: true
    t.index ["tag_definition_id"], name: "index_tag_joins_on_tag_definition_id"
  end

  create_table "tag_joins_backup", id: :serial, force: :cascade do |t|
    t.integer "tag_definition_id"
    t.integer "supporter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "metadata"
  end

  create_table "ticket_levels", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "amount"
    t.integer "quantity"
    t.string "name", limit: 255
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
    t.integer "limit"
    t.integer "event_discount_id"
    t.boolean "admin_only"
    t.integer "order"
  end

  create_table "ticket_purchases", id: :string, force: :cascade do |t|
    t.integer "amount"
    t.integer "original_discount", default: 0
    t.bigint "event_discount_id"
    t.bigint "event_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_discount_id"], name: "index_ticket_purchases_on_event_discount_id"
    t.index ["event_id"], name: "index_ticket_purchases_on_event_id"
  end

  create_table "ticket_to_legacy_tickets", id: :string, force: :cascade do |t|
    t.string "ticket_purchase_id"
    t.bigint "ticket_id"
    t.integer "amount", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ticket_id"], name: "index_ticket_to_legacy_tickets_on_ticket_id"
    t.index ["ticket_purchase_id"], name: "index_ticket_to_legacy_tickets_on_ticket_purchase_id"
  end

  create_table "tickets", id: :serial, force: :cascade do |t|
    t.integer "ticket_level_id"
    t.integer "charge_id"
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "supporter_id"
    t.integer "event_id"
    t.integer "quantity"
    t.boolean "checked_in", default: false, null: false
    t.integer "bid_id"
    t.integer "card_id"
    t.integer "payment_id"
    t.text "note"
    t.integer "event_discount_id"
    t.boolean "deleted", default: false, null: false
    t.uuid "source_token_id"
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["payment_id"], name: "index_tickets_on_payment_id"
    t.index ["supporter_id"], name: "index_tickets_on_supporter_id"
  end

  create_table "trackings", id: :serial, force: :cascade do |t|
    t.string "utm_campaign", limit: 255
    t.string "utm_medium", limit: 255
    t.string "utm_source", limit: 255
    t.integer "donation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "utm_content", limit: 255
  end

  create_table "transaction_assignments", id: :string, force: :cascade do |t|
    t.string "transaction_id", null: false
    t.string "assignable_type", null: false
    t.string "assignable_id", null: false
    t.index ["assignable_type", "assignable_id"], name: "index_transaction_assignments_on_assignable", unique: true
    t.index ["transaction_id"], name: "index_transaction_assignments_on_transaction_id"
  end

  create_table "transactions", id: :string, force: :cascade do |t|
    t.bigint "supporter_id"
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "created", comment: "the moment that the offline_transaction was created. Could be earlier than created_at if the transaction was in the past."
    t.index ["supporter_id"], name: "index_transactions_on_supporter_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email", limit: 255
    t.string "phone"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campaign_gift_purchases", "campaigns"
  add_foreign_key "modern_campaign_gifts", "campaign_gift_purchases"
  add_foreign_key "modern_campaign_gifts", "campaign_gifts"
  add_foreign_key "object_event_hook_configs", "nonprofits"
  add_foreign_key "offline_transaction_charges", "payments"
  add_foreign_key "offline_transaction_disputes", "payments"
  add_foreign_key "offline_transaction_refunds", "payments"
  add_foreign_key "recurrences", "recurring_donations"
  add_foreign_key "recurrences", "supporters"
  add_foreign_key "stripe_charges", "payments"
  add_foreign_key "stripe_disputes", "payments"
  add_foreign_key "stripe_refunds", "payments"
  add_foreign_key "subtransaction_payments", "subtransactions"
  add_foreign_key "subtransactions", "transactions"
  add_foreign_key "ticket_purchases", "event_discounts"
  add_foreign_key "ticket_purchases", "events"
  add_foreign_key "ticket_to_legacy_tickets", "ticket_purchases"
  add_foreign_key "ticket_to_legacy_tickets", "tickets"
  add_foreign_key "transaction_assignments", "transactions"
  add_foreign_key "transactions", "supporters"
end
