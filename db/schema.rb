# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20230307171832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "uuid-ossp"

  create_table "activities", force: :cascade do |t|
    t.integer  "supporter_id"
    t.integer  "host_id"
    t.string   "host_type",       limit: 255
    t.string   "action_type",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "attachment_id"
    t.string   "attachment_type", limit: 255
    t.integer  "nonprofit_id"
    t.boolean  "public"
    t.integer  "user_id"
    t.datetime "date"
    t.string   "kind",            limit: 255
    t.jsonb    "json_data"
  end

  add_index "activities", ["attachment_type", "attachment_id"], name: "index_activities_on_attachment_type_and_attachment_id", using: :btree
  add_index "activities", ["nonprofit_id"], name: "index_activities_on_nonprofit_id", using: :btree
  add_index "activities", ["supporter_id"], name: "index_activities_on_supporter_id", using: :btree

  create_table "ar_internal_metadata", primary_key: "key", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.string   "account_number",            limit: 255
    t.string   "bank_name",                 limit: 255
    t.string   "email",                     limit: 255
    t.integer  "nonprofit_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "pending_verification"
    t.string   "confirmation_token",        limit: 255
    t.string   "status",                    limit: 255
    t.string   "stripe_bank_account_token", limit: 255
    t.string   "stripe_bank_account_id",    limit: 255
    t.boolean  "deleted",                               default: false
  end

  create_table "billing_plans", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "stripe_plan_id", limit: 255
    t.integer  "amount"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "tier"
    t.string   "interval",       limit: 255
    t.decimal  "percentage_fee",             default: 0.0, null: false
    t.integer  "flat_fee",                   default: 0,   null: false
  end

  create_table "billing_subscriptions", force: :cascade do |t|
    t.integer  "nonprofit_id"
    t.integer  "billing_plan_id"
    t.string   "stripe_subscription_id", limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "status",                 limit: 255
  end

  add_index "billing_subscriptions", ["nonprofit_id", "billing_plan_id"], name: "index_billing_subscriptions_on_nonprofit_id_and_billing_plan_id", using: :btree
  add_index "billing_subscriptions", ["nonprofit_id"], name: "index_billing_subscriptions_on_nonprofit_id", using: :btree

  create_table "campaign_gift_options", force: :cascade do |t|
    t.integer  "amount_one_time"
    t.text     "description"
    t.string   "name",               limit: 255
    t.integer  "campaign_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "amount_dollars",     limit: 255
    t.integer  "amount_recurring"
    t.integer  "quantity"
    t.boolean  "to_ship"
    t.integer  "order"
    t.boolean  "hide_contributions"
  end

  create_table "campaign_gifts", force: :cascade do |t|
    t.integer  "donation_id"
    t.integer  "campaign_gift_option_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "recurring_donation_id"
  end

  add_index "campaign_gifts", ["campaign_gift_option_id"], name: "index_campaign_gifts_on_campaign_gift_option_id", using: :btree
  add_index "campaign_gifts", ["donation_id"], name: "index_campaign_gifts_on_donation_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.string   "url",                           limit: 255
    t.integer  "total_raised"
    t.integer  "goal_amount"
    t.integer  "nonprofit_id"
    t.integer  "profile_id"
    t.string   "main_image",                    limit: 255
    t.string   "vimeo_video_id",                limit: 255
    t.text     "summary"
    t.text     "body"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "published"
    t.string   "background_image",              limit: 255
    t.integer  "total_supporters"
    t.string   "slug",                          limit: 255
    t.string   "youtube_video_id",              limit: 255
    t.string   "tagline",                       limit: 255
    t.text     "video_url"
    t.boolean  "show_total_raised",                         default: true
    t.boolean  "show_total_count",                          default: true
    t.boolean  "hide_activity_feed"
    t.boolean  "deleted",                                   default: false
    t.boolean  "hide_title"
    t.boolean  "hide_thermometer"
    t.boolean  "hide_goal"
    t.text     "receipt_message"
    t.boolean  "hide_custom_amounts"
    t.boolean  "show_recurring_amount",                     default: false
    t.datetime "end_datetime"
    t.string   "external_identifier",           limit: 255
    t.boolean  "goal_is_in_supporters"
    t.integer  "starting_point"
    t.integer  "parent_campaign_id"
    t.text     "reason_for_supporting"
    t.text     "default_reason_for_supporting"
    t.string   "banner_image",                  limit: 255
    t.integer  "widget_description_id"
  end

  add_index "campaigns", ["parent_campaign_id"], name: "index_campaigns_on_parent_campaign_id", using: :btree
  add_index "campaigns", ["widget_description_id"], name: "index_campaigns_on_widget_description_id", using: :btree

  create_table "cards", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "status",             limit: 255
    t.integer  "profile_id"
    t.string   "email",              limit: 255
    t.integer  "expiration_month"
    t.integer  "expiration_year"
    t.integer  "supporter_id"
    t.string   "stripe_card_token",  limit: 255
    t.string   "stripe_card_id",     limit: 255
    t.integer  "holder_id"
    t.string   "holder_type",        limit: 255
    t.string   "stripe_customer_id", limit: 255
    t.boolean  "deleted",                        default: false
    t.boolean  "inactive"
    t.string   "country",            limit: 255
  end

  add_index "cards", ["holder_id", "holder_type"], name: "index_cards_on_holder_id_and_holder_type", using: :btree
  add_index "cards", ["id", "holder_type", "holder_id", "inactive"], name: "index_cards_on_id_and_holder_type_and_holder_id_and_inactive", using: :btree

  create_table "charges", force: :cascade do |t|
    t.integer  "amount"
    t.string   "stripe_charge_id",       limit: 255
    t.boolean  "disbursed"
    t.string   "failure_message",        limit: 255
    t.integer  "card_id"
    t.integer  "nonprofit_id"
    t.integer  "supporter_id"
    t.integer  "profile_id"
    t.integer  "donation_id"
    t.integer  "ticket_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "payment_id"
    t.string   "status",                 limit: 255
    t.integer  "fee"
    t.integer  "direct_debit_detail_id"
  end

  add_index "charges", ["donation_id"], name: "index_charges_on_donation_id", using: :btree
  add_index "charges", ["payment_id"], name: "index_charges_on_payment_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "profile_id"
    t.text     "body"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "host_id"
    t.string   "host_type",  limit: 255
  end

  create_table "custom_field_joins", force: :cascade do |t|
    t.integer  "custom_field_master_id"
    t.integer  "supporter_id"
    t.text     "value"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "custom_field_joins", ["custom_field_master_id", "supporter_id"], name: "custom_field_join_supporter_unique_idx", unique: true, using: :btree
  add_index "custom_field_joins", ["custom_field_master_id"], name: "custom_field_joins_custom_field_master_id", using: :btree
  add_index "custom_field_joins", ["supporter_id"], name: "index_custom_field_joins_on_supporter_id", using: :btree

  create_table "custom_field_masters", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "nonprofit_id"
    t.boolean  "deleted",                  default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "custom_field_masters", ["nonprofit_id"], name: "index_custom_field_masters_on_nonprofit_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "direct_debit_details", force: :cascade do |t|
    t.string   "iban",                limit: 255
    t.string   "account_holder_name", limit: 255
    t.string   "bic",                 limit: 255
    t.integer  "holder_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "dispute_payment_backups", force: :cascade do |t|
    t.integer "dispute_id"
    t.integer "payment_id"
  end

  create_table "dispute_transactions", force: :cascade do |t|
    t.integer  "dispute_id"
    t.integer  "payment_id"
    t.integer  "gross_amount",                      default: 0
    t.integer  "fee_total",                         default: 0
    t.integer  "net_amount",                        default: 0
    t.boolean  "disbursed",                         default: false
    t.string   "stripe_transaction_id", limit: 255
    t.datetime "date"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "dispute_transactions", ["dispute_id"], name: "index_dispute_transactions_on_dispute_id", using: :btree
  add_index "dispute_transactions", ["payment_id"], name: "index_dispute_transactions_on_payment_id", using: :btree

  create_table "disputes", force: :cascade do |t|
    t.integer  "gross_amount"
    t.integer  "charge_id"
    t.string   "reason",            limit: 255
    t.string   "status",            limit: 255
    t.string   "stripe_dispute_id", limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.datetime "started_at"
    t.boolean  "is_legacy",                     default: false
  end

  add_index "disputes", ["stripe_dispute_id"], name: "index_disputes_on_stripe_dispute_id", unique: true, using: :btree

  create_table "donations", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "profile_id"
    t.integer  "nonprofit_id"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "card_id"
    t.text     "designation"
    t.boolean  "offsite"
    t.boolean  "anonymous",                          default: false, null: false
    t.integer  "supporter_id"
    t.text     "origin_url"
    t.boolean  "manual"
    t.integer  "campaign_id"
    t.integer  "recurring_donation_id"
    t.text     "comment"
    t.boolean  "recurring"
    t.text     "dedication"
    t.integer  "event_id"
    t.datetime "imported_at"
    t.integer  "charge_id"
    t.integer  "payment_id"
    t.string   "category",               limit: 255
    t.datetime "date"
    t.datetime "queued_for_import_at"
    t.integer  "direct_debit_detail_id"
    t.string   "payment_provider",       limit: 255
    t.tsvector "fts"
  end

  add_index "donations", ["amount"], name: "donations_amount", using: :btree
  add_index "donations", ["anonymous"], name: "index_donations_on_anonymous", using: :btree
  add_index "donations", ["campaign_id"], name: "donations_campaign_id", using: :btree
  add_index "donations", ["event_id"], name: "donations_event_id", using: :btree
  add_index "donations", ["event_id"], name: "index_donations_on_event_id", using: :btree
  add_index "donations", ["fts"], name: "donations_fts_idx", using: :gin
  add_index "donations", ["nonprofit_id"], name: "index_donations_on_nonprofit_id", using: :btree
  add_index "donations", ["supporter_id"], name: "donations_supporter_id", using: :btree

  create_table "donations_payment_imports", id: false, force: :cascade do |t|
    t.integer "donation_id"
    t.integer "payment_import_id"
  end

  create_table "e_tap_import_contacts", force: :cascade do |t|
    t.integer  "e_tap_import_id"
    t.jsonb    "row"
    t.integer  "supporter_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "e_tap_import_contacts", ["e_tap_import_id"], name: "index_e_tap_import_contacts_on_e_tap_import_id", using: :btree
  add_index "e_tap_import_contacts", ["supporter_id"], name: "index_e_tap_import_contacts_on_supporter_id", using: :btree

  create_table "e_tap_import_journal_entries", force: :cascade do |t|
    t.integer  "e_tap_import_id"
    t.jsonb    "row"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "e_tap_import_journal_entries", ["e_tap_import_id"], name: "index_e_tap_import_journal_entries_on_e_tap_import_id", using: :btree

  create_table "e_tap_imports", force: :cascade do |t|
    t.integer  "nonprofit_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "email_lists", force: :cascade do |t|
    t.integer  "nonprofit_id",                  null: false
    t.integer  "tag_master_id",                 null: false
    t.string   "list_name",         limit: 255, null: false
    t.string   "mailchimp_list_id", limit: 255, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "email_settings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.boolean "notify_payments"
    t.boolean "notify_campaigns"
    t.boolean "notify_events"
    t.boolean "notify_payouts"
    t.boolean "notify_recurring_donations"
  end

  create_table "event_discounts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.integer  "event_id"
    t.integer  "percent"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "tagline",            limit: 255
    t.text     "summary"
    t.text     "body"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "location",           limit: 255
    t.string   "main_image",         limit: 255
    t.string   "background_image",   limit: 255
    t.integer  "nonprofit_id"
    t.boolean  "published"
    t.string   "slug",               limit: 255
    t.integer  "total_raised"
    t.text     "directions"
    t.string   "venue_name",         limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "profile_id"
    t.string   "city",               limit: 255
    t.string   "state_code",         limit: 255
    t.string   "address",            limit: 255
    t.string   "zip_code",           limit: 255
    t.boolean  "show_total_raised",              default: false
    t.boolean  "show_total_count",               default: false
    t.boolean  "hide_activity_feed"
    t.boolean  "hide_title"
    t.boolean  "deleted",                        default: false
    t.text     "receipt_message"
    t.string   "organizer_email",    limit: 255
    t.datetime "start_datetime"
    t.datetime "end_datetime"
  end

  add_index "events", ["nonprofit_id", "deleted", "published", "end_datetime"], name: "events_nonprofit_id_not_deleted_and_published_endtime", using: :btree
  add_index "events", ["nonprofit_id", "deleted", "published"], name: "index_events_on_nonprofit_id_and_deleted_and_published", using: :btree
  add_index "events", ["nonprofit_id"], name: "index_events_on_nonprofit_id", using: :btree

  create_table "export_formats", force: :cascade do |t|
    t.string  "name",                                     null: false
    t.string  "date_format"
    t.boolean "show_currency",             default: true, null: false
    t.jsonb   "custom_columns_and_values"
    t.integer "nonprofit_id",                             null: false
  end

  add_index "export_formats", ["nonprofit_id"], name: "index_export_formats_on_nonprofit_id", using: :btree

  create_table "exports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "nonprofit_id"
    t.string   "status",       limit: 255
    t.text     "exception"
    t.datetime "ended"
    t.string   "export_type",  limit: 255
    t.text     "parameters"
    t.string   "url",          limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "exports", ["nonprofit_id"], name: "index_exports_on_nonprofit_id", using: :btree
  add_index "exports", ["user_id"], name: "index_exports_on_user_id", using: :btree

  create_table "fee_coverage_detail_bases", force: :cascade do |t|
    t.integer  "flat_fee"
    t.decimal  "percentage_fee"
    t.boolean  "dont_consider_billing_plan", default: false, null: false
    t.integer  "fee_era_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "fee_coverage_detail_bases", ["fee_era_id"], name: "index_fee_coverage_detail_bases_on_fee_era_id", using: :btree

  create_table "fee_eras", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "local_country"
    t.decimal  "international_surcharge_fee"
    t.boolean  "refund_stripe_fee",           default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "fee_structures", force: :cascade do |t|
    t.string   "brand"
    t.integer  "flat_fee"
    t.decimal  "stripe_fee"
    t.integer  "fee_era_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "fee_structures", ["fee_era_id"], name: "index_fee_structures_on_fee_era_id", using: :btree

  create_table "full_contact_infos", force: :cascade do |t|
    t.string   "email",            limit: 255
    t.string   "full_name",        limit: 255
    t.string   "gender",           limit: 255
    t.string   "city",             limit: 255
    t.string   "county",           limit: 255
    t.string   "state_code",       limit: 255
    t.string   "country",          limit: 255
    t.string   "continent",        limit: 255
    t.string   "age",              limit: 255
    t.string   "age_range",        limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "supporter_id"
    t.string   "location_general", limit: 255
    t.text     "websites"
  end

  add_index "full_contact_infos", ["supporter_id"], name: "index_full_contact_infos_on_supporter_id", using: :btree

  create_table "full_contact_jobs", force: :cascade do |t|
    t.integer "supporter_id"
  end

  create_table "full_contact_orgs", force: :cascade do |t|
    t.boolean  "is_primary"
    t.string   "name",                 limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.string   "title",                limit: 255
    t.boolean  "current"
    t.integer  "full_contact_info_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "full_contact_orgs", ["full_contact_info_id"], name: "index_full_contact_orgs_on_full_contact_info_id", using: :btree

  create_table "full_contact_photos", force: :cascade do |t|
    t.integer  "full_contact_info_id"
    t.string   "type_id",              limit: 255
    t.boolean  "is_primary"
    t.text     "url"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "full_contact_photos", ["full_contact_info_id", "is_primary"], name: "index_full_context_photo_info_primary", using: :btree

  create_table "full_contact_social_profiles", force: :cascade do |t|
    t.integer  "full_contact_info_id"
    t.string   "type_id",              limit: 255
    t.string   "username",             limit: 255
    t.string   "uid",                  limit: 255
    t.text     "bio"
    t.string   "url",                  limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "followers"
    t.integer  "following"
  end

  add_index "full_contact_social_profiles", ["full_contact_info_id"], name: "index_full_contact_social_profiles_on_full_contact_info_id", using: :btree

  create_table "full_contact_topics", force: :cascade do |t|
    t.string   "provider",             limit: 255
    t.string   "value",                limit: 255
    t.integer  "full_contact_info_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "full_contact_topics", ["full_contact_info_id"], name: "index_full_contact_topics_on_full_contact_info_id", using: :btree

  create_table "image_attachments", force: :cascade do |t|
    t.string   "file",        limit: 255
    t.integer  "parent_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "parent_type", limit: 255
  end

  create_table "imports", force: :cascade do |t|
    t.integer  "row_count"
    t.datetime "date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "imported_count"
    t.integer  "nonprofit_id"
    t.integer  "user_id"
  end

  create_table "journal_entries_to_items", force: :cascade do |t|
    t.integer "e_tap_import_journal_entry_id"
    t.integer "item_id"
    t.string  "item_type"
  end

  create_table "manual_balance_adjustments", force: :cascade do |t|
    t.integer  "gross_amount",  default: 0
    t.integer  "fee_total",     default: 0
    t.integer  "net_amount",    default: 0
    t.integer  "payment_id"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.text     "staff_comment"
    t.boolean  "disbursed",     default: false
    t.jsonb    "metadata"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "misc_campaign_infos", force: :cascade do |t|
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "campaign_id"
    t.boolean  "manual_cover_fees"
    t.boolean  "hide_cover_fees_option"
    t.boolean  "paused",                 default: false, null: false
  end

  add_index "misc_campaign_infos", ["campaign_id"], name: "index_misc_campaign_infos_on_campaign_id", using: :btree

  create_table "misc_event_infos", force: :cascade do |t|
    t.integer  "event_id"
    t.boolean  "hide_cover_fees_option"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "custom_get_tickets_button_label"
  end

  create_table "misc_payment_infos", force: :cascade do |t|
    t.integer  "payment_id"
    t.boolean  "fee_covered"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "misc_payment_infos", ["payment_id"], name: "index_misc_payment_infos_on_payment_id", using: :btree

  create_table "misc_recurring_donation_infos", force: :cascade do |t|
    t.integer  "recurring_donation_id"
    t.boolean  "fee_covered"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "misc_recurring_donation_infos", ["recurring_donation_id"], name: "index_misc_recurring_donation_infos_on_recurring_donation_id", using: :btree

  create_table "misc_refund_infos", force: :cascade do |t|
    t.boolean  "is_modern"
    t.string   "stripe_application_fee_refund_id", limit: 255
    t.integer  "refund_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "miscellaneous_np_infos", force: :cascade do |t|
    t.string   "donate_again_url",        limit: 255
    t.integer  "nonprofit_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.text     "change_amount_message"
    t.boolean  "first_charge_email_sent"
    t.boolean  "hide_cover_fees",                     default: false, null: false
  end

  add_index "miscellaneous_np_infos", ["nonprofit_id"], name: "index_miscellaneous_np_infos_on_nonprofit_id", using: :btree

  create_table "modern_donations", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "donation_id", null: false
    t.string   "houid",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "modern_donations", ["houid"], name: "index_modern_donations_on_houid", unique: true, using: :btree

  create_table "nonprofit_deactivations", force: :cascade do |t|
    t.integer  "nonprofit_id"
    t.boolean  "deactivated"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "nonprofit_keys", force: :cascade do |t|
    t.integer  "nonprofit_id"
    t.jsonb    "mailchimp_token"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "nonprofit_s3_keys", force: :cascade do |t|
    t.integer  "nonprofit_id"
    t.string   "access_key_id"
    t.string   "secret_access_key"
    t.string   "bucket_name"
    t.string   "region"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "nonprofit_s3_keys", ["nonprofit_id"], name: "index_nonprofit_s3_keys_on_nonprofit_id", using: :btree

  create_table "nonprofit_verification_backups", force: :cascade do |t|
    t.string "verification_status", limit: 255
  end

  create_table "nonprofit_verification_process_statuses", force: :cascade do |t|
    t.string   "stripe_account_id",  limit: 255, null: false
    t.datetime "started_at"
    t.string   "email_to_send_guid", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "nonprofit_verification_process_statuses", ["stripe_account_id"], name: "index_nonprofit_verification_to_stripe", unique: true, using: :btree

  create_table "nonprofits", force: :cascade do |t|
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.string   "name",                                        limit: 255
    t.string   "tagline",                                     limit: 255
    t.string   "phone",                                       limit: 255
    t.string   "email",                                       limit: 255
    t.string   "main_image",                                  limit: 255
    t.string   "website",                                     limit: 255
    t.string   "background_image",                            limit: 255
    t.string   "logo",                                        limit: 255
    t.text     "summary"
    t.text     "categories_legacy"
    t.string   "ein",                                         limit: 255
    t.text     "full_description"
    t.text     "achievements_legacy"
    t.string   "state_code",                                  limit: 255
    t.string   "city",                                        limit: 255
    t.string   "slug",                                        limit: 255
    t.boolean  "published"
    t.text     "address"
    t.boolean  "vetted"
    t.string   "zip_code",                                    limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.string   "state_code_slug",                             limit: 255
    t.string   "city_slug",                                   limit: 255
    t.string   "referrer",                                    limit: 255
    t.text     "thank_you_note"
    t.boolean  "no_anon"
    t.string   "timezone",                                    limit: 255
    t.string   "statement",                                   limit: 255
    t.string   "brand_color",                                 limit: 255
    t.string   "brand_font",                                  limit: 255
    t.string   "stripe_account_id",                           limit: 255
    t.boolean  "hide_activity_feed"
    t.text     "tracking_script",                                         default: ""
    t.string   "facebook",                                    limit: 255
    t.string   "twitter",                                     limit: 255
    t.string   "youtube",                                     limit: 255
    t.string   "instagram",                                   limit: 255
    t.string   "blog",                                        limit: 255
    t.text     "card_failure_message_top"
    t.text     "card_failure_message_bottom"
    t.text     "fields_needed"
    t.boolean  "autocomplete_supporter_address",                          default: false
    t.string   "currency",                                    limit: 255, default: "usd"
    t.boolean  "feature_flag_autocomplete_supporter_address",             default: false
    t.string   "houid"
    t.jsonb    "achievements"
    t.jsonb    "categories"
  end

  create_table "object_events", force: :cascade do |t|
    t.integer  "event_entity_id"
    t.string   "event_entity_type"
    t.string   "event_type"
    t.string   "event_entity_houid"
    t.integer  "nonprofit_id"
    t.string   "houid"
    t.datetime "created"
    t.jsonb    "object_json"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "object_events", ["event_entity_houid"], name: "index_object_events_on_event_entity_houid", using: :btree
  add_index "object_events", ["event_entity_type", "event_entity_id"], name: "index_object_events_on_event_entity_type_and_event_entity_id", using: :btree
  add_index "object_events", ["event_entity_type"], name: "index_object_events_on_event_entity_type", using: :btree
  add_index "object_events", ["event_type"], name: "index_object_events_on_event_type", using: :btree
  add_index "object_events", ["houid"], name: "index_object_events_on_houid", using: :btree
  add_index "object_events", ["nonprofit_id"], name: "index_object_events_on_nonprofit_id", using: :btree

  create_table "offline_transaction_charges", force: :cascade do |t|
    t.string   "houid",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offline_transaction_charges", ["houid"], name: "index_offline_transaction_charges_on_houid", unique: true, using: :btree

  create_table "offline_transactions", force: :cascade do |t|
    t.integer  "amount",     null: false
    t.string   "houid",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offline_transactions", ["houid"], name: "index_offline_transactions_on_houid", unique: true, using: :btree

  create_table "offsite_payments", force: :cascade do |t|
    t.integer  "gross_amount"
    t.string   "kind",         limit: 255
    t.integer  "nonprofit_id"
    t.integer  "supporter_id"
    t.integer  "donation_id"
    t.integer  "payment_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.datetime "date"
    t.string   "check_number", limit: 255
    t.integer  "user_id"
  end

  add_index "offsite_payments", ["check_number"], name: "index_offsite_payments_on_check_number", using: :btree
  add_index "offsite_payments", ["payment_id"], name: "index_offsite_payments_on_payment_id", using: :btree
  add_index "offsite_payments", ["supporter_id"], name: "index_offsite_payments_on_supporter_id", using: :btree

  create_table "payment_dupe_statuses", force: :cascade do |t|
    t.integer  "payment_id"
    t.boolean  "matched",              default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "matched_with_offline", default: [],                 array: true
  end

  add_index "payment_dupe_statuses", ["payment_id"], name: "index_payment_dupe_statuses_on_payment_id", using: :btree

  create_table "payment_imports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "nonprofit_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "payment_payouts", force: :cascade do |t|
    t.integer  "donation_id"
    t.integer  "payout_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "total_fees"
    t.integer  "charge_id"
    t.integer  "payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "gross_amount"
    t.integer  "refund_total",             default: 0
    t.integer  "fee_total"
    t.integer  "net_amount"
    t.integer  "nonprofit_id"
    t.integer  "supporter_id"
    t.string   "towards",      limit: 255
    t.string   "kind",         limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "donation_id"
    t.datetime "date"
  end

  add_index "payments", ["date"], name: "payments_date", using: :btree
  add_index "payments", ["donation_id"], name: "payments_donation_id", using: :btree
  add_index "payments", ["gross_amount"], name: "payments_gross_amount", using: :btree
  add_index "payments", ["kind"], name: "payments_kind", using: :btree
  add_index "payments", ["nonprofit_id"], name: "payments_nonprofit_id", using: :btree
  add_index "payments", ["supporter_id"], name: "payments_supporter_id", using: :btree

  create_table "payouts", force: :cascade do |t|
    t.integer  "net_amount"
    t.integer  "nonprofit_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "failure_message",    limit: 255
    t.string   "status",             limit: 255
    t.integer  "fee_total"
    t.integer  "gross_amount"
    t.string   "bank_name",          limit: 255
    t.string   "email",              limit: 255
    t.integer  "count"
    t.boolean  "manual"
    t.boolean  "scheduled"
    t.string   "stripe_transfer_id", limit: 255
    t.string   "user_ip",            limit: 255
    t.integer  "ach_fee"
    t.string   "houid"
  end

  add_index "payouts", ["houid"], name: "index_payouts_on_houid", unique: true, using: :btree

  create_table "periodic_reports", force: :cascade do |t|
    t.boolean "active",              default: false, null: false
    t.string  "report_type",                         null: false
    t.string  "period",                              null: false
    t.integer "user_id"
    t.integer "nonprofit_id"
    t.string  "filename"
    t.integer "nonprofit_s3_key_id"
  end

  add_index "periodic_reports", ["nonprofit_id"], name: "index_periodic_reports_on_nonprofit_id", using: :btree
  add_index "periodic_reports", ["user_id"], name: "index_periodic_reports_on_user_id", using: :btree

  create_table "periodic_reports_users", force: :cascade do |t|
    t.integer "periodic_report_id"
    t.integer "user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "user_id"
    t.integer  "admin_id"
    t.string   "state_code",      limit: 255
    t.string   "city",            limit: 255
    t.string   "picture",         limit: 255
    t.string   "phone",           limit: 255
    t.string   "address",         limit: 255
    t.boolean  "anonymous"
    t.string   "zip_code",        limit: 255
    t.integer  "total_recurring"
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
    t.text     "mini_bio"
    t.string   "country",         limit: 255, default: "US"
  end

  create_table "reassignments", force: :cascade do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "e_tap_import_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "source_supporter_id"
    t.integer  "target_supporter_id"
  end

  add_index "reassignments", ["e_tap_import_id"], name: "index_reassignments_on_e_tap_import_id", using: :btree

  create_table "recaptcha_rejections", force: :cascade do |t|
    t.text     "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recurring_donation_holds", force: :cascade do |t|
    t.integer  "recurring_donation_id"
    t.datetime "end_date"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "recurring_donations", force: :cascade do |t|
    t.boolean  "active"
    t.integer  "paydate"
    t.integer  "card_id"
    t.integer  "nonprofit_id"
    t.integer  "campaign_id"
    t.string   "origin_url",      limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "profile_id"
    t.integer  "amount"
    t.integer  "supporter_id"
    t.string   "email",           limit: 255
    t.string   "edit_token",      limit: 255
    t.string   "failure_message", limit: 255
    t.integer  "interval"
    t.string   "time_unit",       limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "anonymous",                   default: false, null: false
    t.integer  "donation_id"
    t.integer  "n_failures"
    t.string   "cancelled_by",    limit: 255
    t.datetime "cancelled_at"
  end

  add_index "recurring_donations", ["donation_id"], name: "index_recurring_donations_on_donation_id", using: :btree
  add_index "recurring_donations", ["supporter_id"], name: "index_recurring_donations_on_supporter_id", using: :btree

  create_table "refunds", force: :cascade do |t|
    t.integer  "amount"
    t.text     "comment"
    t.integer  "charge_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "stripe_refund_id", limit: 255
    t.string   "reason",           limit: 255
    t.boolean  "disbursed"
    t.integer  "user_id"
    t.integer  "payment_id"
  end

  add_index "refunds", ["charge_id"], name: "index_refunds_on_charge_id", using: :btree
  add_index "refunds", ["payment_id"], name: "index_refunds_on_payment_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user_id"
    t.integer  "host_id"
    t.string   "host_type",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "roles", ["name", "user_id", "host_id"], name: "index_roles_on_name_and_user_id_and_host_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "simple_objects", force: :cascade do |t|
    t.string   "houid"
    t.integer  "parent_id"
    t.integer  "friend_id"
    t.integer  "nonprofit_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "source_tokens", id: false, force: :cascade do |t|
    t.uuid     "token",                                    null: false
    t.datetime "expiration"
    t.integer  "tokenizable_id"
    t.string   "tokenizable_type", limit: 255
    t.integer  "event_id"
    t.integer  "max_uses",                     default: 1
    t.integer  "total_uses",                   default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "source_tokens", ["expiration"], name: "index_source_tokens_on_expiration", using: :btree
  add_index "source_tokens", ["token"], name: "index_source_tokens_on_token", unique: true, using: :btree
  add_index "source_tokens", ["tokenizable_id", "tokenizable_type"], name: "index_source_tokens_on_tokenizable_id_and_tokenizable_type", using: :btree

  create_table "stripe_accounts", force: :cascade do |t|
    t.string   "stripe_account_id",    limit: 255, null: false
    t.jsonb    "object",                           null: false
    t.boolean  "charges_enabled"
    t.boolean  "payouts_enabled"
    t.string   "disabled_reason",      limit: 255
    t.jsonb    "eventually_due"
    t.jsonb    "currently_due"
    t.jsonb    "past_due"
    t.jsonb    "pending_verification"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "stripe_accounts", ["id"], name: "index_stripe_accounts_on_id", using: :btree
  add_index "stripe_accounts", ["stripe_account_id"], name: "index_stripe_accounts_on_stripe_account_id", using: :btree

  create_table "stripe_charges", force: :cascade do |t|
    t.jsonb    "object",           null: false
    t.string   "stripe_charge_id", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "stripe_charges", ["stripe_charge_id"], name: "index_stripe_charges_on_stripe_charge_id", using: :btree

  create_table "stripe_disputes", force: :cascade do |t|
    t.jsonb    "object"
    t.jsonb    "balance_transactions"
    t.string   "stripe_dispute_id",    limit: 255
    t.string   "stripe_charge_id",     limit: 255
    t.string   "status",               limit: 255
    t.string   "reason",               limit: 255
    t.integer  "net_change"
    t.integer  "amount"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "evidence_due_date"
    t.datetime "started_at"
  end

  add_index "stripe_disputes", ["id"], name: "index_stripe_disputes_on_id", using: :btree
  add_index "stripe_disputes", ["stripe_charge_id"], name: "index_stripe_disputes_on_stripe_charge_id", using: :btree
  add_index "stripe_disputes", ["stripe_dispute_id"], name: "index_stripe_disputes_on_stripe_dispute_id", unique: true, using: :btree

  create_table "stripe_events", force: :cascade do |t|
    t.string   "object_id",  limit: 255
    t.string   "event_id",   limit: 255
    t.datetime "event_time"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "stripe_events", ["event_id"], name: "index_stripe_events_on_event_id", using: :btree
  add_index "stripe_events", ["object_id", "event_time"], name: "index_stripe_events_on_object_id_and_event_time", using: :btree

  create_table "stripe_transaction_charges", force: :cascade do |t|
    t.string   "houid",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_transaction_charges", ["houid"], name: "index_stripe_transaction_charges_on_houid", using: :btree

  create_table "stripe_transaction_dispute_reversals", force: :cascade do |t|
    t.string   "houid",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_transaction_dispute_reversals", ["houid"], name: "index_stripe_transaction_dispute_reversals_on_houid", using: :btree

  create_table "stripe_transaction_disputes", force: :cascade do |t|
    t.string   "houid",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_transaction_disputes", ["houid"], name: "index_stripe_transaction_disputes_on_houid", using: :btree

  create_table "stripe_transaction_refunds", force: :cascade do |t|
    t.string   "houid",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_transaction_refunds", ["houid"], name: "index_stripe_transaction_refunds_on_houid", using: :btree

  create_table "stripe_transactions", force: :cascade do |t|
    t.integer  "amount",     null: false
    t.string   "houid",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_transactions", ["houid"], name: "index_stripe_transactions_on_houid", using: :btree

  create_table "subtransaction_payments", force: :cascade do |t|
    t.integer  "subtransaction_id", null: false
    t.integer  "paymentable_id",    null: false
    t.string   "paymentable_type",  null: false
    t.datetime "created"
    t.integer  "legacy_payment_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subtransaction_payments", ["legacy_payment_id"], name: "index_subtransaction_payments_on_legacy_payment_id", unique: true, using: :btree
  add_index "subtransaction_payments", ["paymentable_type", "paymentable_id"], name: "idx_subtrxpayments_on_subtransactable_polymorphic", unique: true, using: :btree

  create_table "subtransactions", force: :cascade do |t|
    t.integer  "transaction_id",       null: false
    t.integer  "subtransactable_id",   null: false
    t.string   "subtransactable_type", null: false
    t.datetime "created"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subtransactions", ["subtransactable_type", "subtransactable_id"], name: "idx_subtrx_on_subtransactable_polymorphic", unique: true, using: :btree

  create_table "supporter_addresses", force: :cascade do |t|
    t.string   "address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state_code"
    t.string   "country"
    t.boolean  "deleted",      default: false, null: false
    t.integer  "supporter_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "supporter_addresses", ["supporter_id"], name: "index_supporter_addresses_on_supporter_id", using: :btree

  create_table "supporter_emails", force: :cascade do |t|
    t.text     "to"
    t.string   "from",            limit: 255
    t.string   "subject",         limit: 255
    t.text     "body"
    t.integer  "supporter_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "nonprofit_id"
    t.integer  "recipient_count"
    t.integer  "user_id"
    t.string   "gmail_thread_id", limit: 255
  end

  create_table "supporter_notes", force: :cascade do |t|
    t.text     "content"
    t.integer  "supporter_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_id"
    t.boolean  "deleted",      default: false
  end

  add_index "supporter_notes", ["supporter_id"], name: "index_supporter_notes_on_supporter_id", using: :btree

  create_table "supporters", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "nonprofit_id"
    t.text     "notes"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.string   "name",                        limit: 255
    t.string   "email",                       limit: 255
    t.string   "phone",                       limit: 255
    t.string   "address",                     limit: 255
    t.string   "city",                        limit: 255
    t.string   "state_code",                  limit: 255
    t.boolean  "anonymous",                               default: false,           null: false
    t.string   "zip_code",                    limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "full_contact_info_id"
    t.boolean  "deleted",                                 default: false
    t.string   "organization",                limit: 255
    t.datetime "imported_at"
    t.string   "country",                     limit: 255, default: "United States"
    t.integer  "import_id"
    t.boolean  "is_unsubscribed_from_emails"
    t.integer  "merged_into"
    t.datetime "merged_at"
    t.string   "region",                      limit: 255
    t.string   "first_name",                  limit: 255
    t.string   "last_name",                   limit: 255
    t.string   "locale",                      limit: 255
    t.tsvector "fts"
    t.string   "phone_index"
    t.integer  "primary_address_id"
    t.string   "houid"
  end

  add_index "supporters", ["anonymous", "nonprofit_id"], name: "index_supporters_on_anonymous_and_nonprofit_id", using: :btree
  add_index "supporters", ["fts"], name: "supporters_fts_idx", using: :gin
  add_index "supporters", ["name"], name: "index_supporters_on_name", using: :btree
  add_index "supporters", ["nonprofit_id", "deleted"], name: "supporters_nonprofit_id_not_deleted", where: "(NOT deleted)", using: :btree
  add_index "supporters", ["nonprofit_id", "imported_at"], name: "index_supporters_on_nonprofit_id_and_imported_at", using: :btree
  add_index "supporters", ["nonprofit_id", "phone_index", "deleted"], name: "index_supporters_on_nonprofit_id_and_phone_index_and_deleted", where: "((phone IS NOT NULL) AND ((phone)::text <> ''::text))", using: :btree
  add_index "supporters", ["nonprofit_id"], name: "supporters_nonprofit_id", where: "(deleted <> true)", using: :btree

  create_table "tag_joins", force: :cascade do |t|
    t.integer  "tag_master_id"
    t.integer  "supporter_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "tag_joins", ["supporter_id"], name: "tag_joins_supporter_id", using: :btree
  add_index "tag_joins", ["tag_master_id", "supporter_id"], name: "tag_join_supporter_unique_idx", unique: true, using: :btree
  add_index "tag_joins", ["tag_master_id"], name: "index_tag_joins_on_tag_master_id", using: :btree
  add_index "tag_joins", ["tag_master_id"], name: "tag_joins_tag_master_id", using: :btree

  create_table "tag_joins_backup", force: :cascade do |t|
    t.integer  "tag_master_id"
    t.integer  "supporter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "metadata"
  end

  create_table "tag_masters", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "nonprofit_id"
    t.boolean  "deleted",                  default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "tag_masters", ["nonprofit_id", "deleted"], name: "tag_masters_nonprofit_id_not_deleted", where: "(NOT deleted)", using: :btree

  create_table "ticket_levels", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "amount"
    t.integer  "quantity"
    t.string   "name",              limit: 255
    t.text     "description"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "deleted",                       default: false
    t.integer  "limit"
    t.integer  "event_discount_id"
    t.boolean  "admin_only"
    t.integer  "order"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "ticket_level_id"
    t.integer  "charge_id"
    t.integer  "profile_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "supporter_id"
    t.integer  "event_id"
    t.integer  "quantity"
    t.boolean  "checked_in"
    t.integer  "bid_id"
    t.integer  "card_id"
    t.integer  "payment_id"
    t.text     "note"
    t.integer  "event_discount_id"
    t.boolean  "deleted",           default: false
    t.uuid     "source_token_id"
  end

  add_index "tickets", ["event_id"], name: "index_tickets_on_event_id", using: :btree
  add_index "tickets", ["payment_id"], name: "index_tickets_on_payment_id", using: :btree
  add_index "tickets", ["supporter_id"], name: "index_tickets_on_supporter_id", using: :btree

  create_table "trackings", force: :cascade do |t|
    t.string   "utm_campaign", limit: 255
    t.string   "utm_medium",   limit: 255
    t.string   "utm_source",   limit: 255
    t.integer  "donation_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "utm_content",  limit: 255
  end

  create_table "transaction_assignments", force: :cascade do |t|
    t.integer "transaction_id",  null: false
    t.integer "assignable_id",   null: false
    t.string  "assignable_type", null: false
  end

  add_index "transaction_assignments", ["assignable_type", "assignable_id"], name: "idx_trx_assignments_assignable_polymorphic", unique: true, using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "supporter_id"
    t.string   "houid",        null: false
    t.integer  "amount"
    t.datetime "created"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["created"], name: "index_transactions_on_created", using: :btree
  add_index "transactions", ["houid"], name: "index_transactions_on_houid", unique: true, using: :btree
  add_index "transactions", ["supporter_id"], name: "index_transactions_on_supporter_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.integer  "user_id"
    t.string   "token",                  limit: 255
    t.string   "secret",                 limit: 255
    t.string   "link",                   limit: 255
    t.string   "name",                   limit: 255
    t.boolean  "auto_generated"
    t.integer  "referer"
    t.boolean  "pending_password"
    t.string   "picture",                limit: 255
    t.string   "city",                   limit: 255
    t.string   "state_code",             limit: 255
    t.string   "location",               limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "phone"
    t.integer  "failed_attempts",                    default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "widget_descriptions", force: :cascade do |t|
    t.string   "houid",                            null: false
    t.string   "custom_recurring_donation_phrase"
    t.jsonb    "custom_amounts"
    t.jsonb    "postfix_element"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "widget_descriptions", ["houid"], name: "index_widget_descriptions_on_houid", unique: true, using: :btree

  add_foreign_key "campaign_gifts", "campaign_gift_options", name: "campaign_gifts_to_option_fk"
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
  create_trigger :update_supporters_fts, sql_definition: <<-SQL
      CREATE TRIGGER update_supporters_fts BEFORE INSERT OR UPDATE ON public.supporters FOR EACH ROW EXECUTE FUNCTION update_fts_on_supporters()
  SQL
  create_trigger :update_supporters_phone_index, sql_definition: <<-SQL
      CREATE TRIGGER update_supporters_phone_index BEFORE INSERT OR UPDATE ON public.supporters FOR EACH ROW EXECUTE FUNCTION update_phone_index_on_supporters()
  SQL
end
