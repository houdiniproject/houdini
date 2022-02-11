--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 13.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: is_valid_json(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_valid_json(p_json text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
  return (p_json::json is not null);
exception
  when others then
     return false;
end;
$$;


--
-- Name: update_fts_on_donations(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_fts_on_donations() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.comment, ''));
          RETURN new;
        END
      $$;


--
-- Name: update_fts_on_supporters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_fts_on_supporters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.name, '') || ' ' || coalesce(new.email, '') || ' ' || coalesce(new.organization, ''));
          RETURN new;
        END
      $$;


--
-- Name: update_phone_index_on_supporters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_phone_index_on_supporters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
              new.phone_index = (regexp_replace(new.phone, '\D','', 'g'));
              RETURN new;
            END
          $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id integer NOT NULL,
    supporter_id integer,
    host_id integer,
    host_type character varying(255),
    action_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_id integer,
    attachment_type character varying(255),
    nonprofit_id integer,
    public boolean,
    user_id integer,
    date timestamp without time zone,
    kind character varying(255),
    json_data jsonb
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_accounts (
    id integer NOT NULL,
    name character varying(255),
    account_number character varying(255),
    bank_name character varying(255),
    email character varying(255),
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pending_verification boolean,
    confirmation_token character varying(255),
    status character varying(255),
    stripe_bank_account_token character varying(255),
    stripe_bank_account_id character varying(255),
    deleted boolean DEFAULT false
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_accounts_id_seq OWNED BY public.bank_accounts.id;


--
-- Name: billing_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_plans (
    id integer NOT NULL,
    name character varying(255),
    stripe_plan_id character varying(255),
    amount integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tier integer,
    "interval" character varying(255),
    percentage_fee numeric DEFAULT 0 NOT NULL,
    flat_fee integer DEFAULT 0 NOT NULL
);


--
-- Name: billing_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billing_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billing_plans_id_seq OWNED BY public.billing_plans.id;


--
-- Name: billing_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_subscriptions (
    id integer NOT NULL,
    nonprofit_id integer,
    billing_plan_id integer,
    stripe_subscription_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying(255)
);


--
-- Name: billing_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billing_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billing_subscriptions_id_seq OWNED BY public.billing_subscriptions.id;


--
-- Name: campaign_gift_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_gift_options (
    id integer NOT NULL,
    amount_one_time integer,
    description text,
    name character varying(255),
    campaign_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    amount_dollars character varying(255),
    amount_recurring integer,
    quantity integer,
    to_ship boolean,
    "order" integer,
    hide_contributions boolean
);


--
-- Name: campaign_gift_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campaign_gift_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_gift_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campaign_gift_options_id_seq OWNED BY public.campaign_gift_options.id;


--
-- Name: campaign_gifts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_gifts (
    id integer NOT NULL,
    donation_id integer,
    campaign_gift_option_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    recurring_donation_id integer
);


--
-- Name: campaign_gifts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campaign_gifts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_gifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campaign_gifts_id_seq OWNED BY public.campaign_gifts.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaigns (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    total_raised integer,
    goal_amount integer,
    nonprofit_id integer,
    profile_id integer,
    main_image character varying(255),
    vimeo_video_id character varying(255),
    summary text,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    published boolean,
    background_image character varying(255),
    total_supporters integer,
    recurring_fund boolean,
    slug character varying(255),
    youtube_video_id character varying(255),
    tagline character varying(255),
    video_url text,
    show_total_raised boolean DEFAULT true,
    show_total_count boolean DEFAULT true,
    hide_activity_feed boolean,
    deleted boolean DEFAULT false,
    hide_title boolean,
    hide_thermometer boolean,
    hide_goal boolean,
    receipt_message text,
    hide_custom_amounts boolean,
    show_recurring_amount boolean DEFAULT false,
    end_datetime timestamp without time zone,
    external_identifier character varying(255),
    goal_is_in_supporters boolean,
    starting_point integer,
    parent_campaign_id integer,
    reason_for_supporting text,
    default_reason_for_supporting text,
    banner_image character varying(255)
);


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campaigns_id_seq OWNED BY public.campaigns.id;


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying(255),
    profile_id integer,
    email character varying(255),
    expiration_month integer,
    expiration_year integer,
    supporter_id integer,
    stripe_card_token character varying(255),
    stripe_card_id character varying(255),
    holder_id integer,
    holder_type character varying(255),
    stripe_customer_id character varying(255),
    deleted boolean DEFAULT false,
    inactive boolean,
    country character varying(255)
);


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cards_id_seq OWNED BY public.cards.id;


--
-- Name: charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.charges (
    id integer NOT NULL,
    amount integer,
    stripe_charge_id character varying(255),
    disbursed boolean,
    failure_message character varying(255),
    card_id integer,
    nonprofit_id integer,
    supporter_id integer,
    profile_id integer,
    donation_id integer,
    ticket_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    payment_id integer,
    status character varying(255),
    fee integer,
    direct_debit_detail_id integer
);


--
-- Name: charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.charges_id_seq OWNED BY public.charges.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    profile_id integer,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    host_id integer,
    host_type character varying(255)
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: custom_field_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_field_joins (
    id integer NOT NULL,
    custom_field_master_id integer,
    supporter_id integer,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_field_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_field_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_field_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_field_joins_id_seq OWNED BY public.custom_field_joins.id;


--
-- Name: custom_field_masters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_field_masters (
    id integer NOT NULL,
    name character varying(255),
    nonprofit_id integer,
    deleted boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_field_masters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_field_masters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_field_masters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_field_masters_id_seq OWNED BY public.custom_field_masters.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: direct_debit_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.direct_debit_details (
    id integer NOT NULL,
    iban character varying(255),
    account_holder_name character varying(255),
    bic character varying(255),
    holder_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: direct_debit_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.direct_debit_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: direct_debit_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.direct_debit_details_id_seq OWNED BY public.direct_debit_details.id;


--
-- Name: dispute_payment_backups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dispute_payment_backups (
    id integer NOT NULL,
    dispute_id integer,
    payment_id integer
);


--
-- Name: dispute_payment_backups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dispute_payment_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dispute_payment_backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dispute_payment_backups_id_seq OWNED BY public.dispute_payment_backups.id;


--
-- Name: dispute_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dispute_transactions (
    id integer NOT NULL,
    dispute_id integer,
    payment_id integer,
    gross_amount integer DEFAULT 0,
    fee_total integer DEFAULT 0,
    net_amount integer DEFAULT 0,
    disbursed boolean DEFAULT false,
    stripe_transaction_id character varying(255),
    date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: dispute_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dispute_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dispute_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dispute_transactions_id_seq OWNED BY public.dispute_transactions.id;


--
-- Name: disputes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disputes (
    id integer NOT NULL,
    gross_amount integer,
    charge_id integer,
    reason character varying(255),
    status character varying(255),
    stripe_dispute_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    is_legacy boolean DEFAULT false
);


--
-- Name: disputes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disputes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disputes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disputes_id_seq OWNED BY public.disputes.id;


--
-- Name: donations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.donations (
    id integer NOT NULL,
    amount integer,
    profile_id integer,
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    card_id integer,
    designation text,
    offsite boolean,
    anonymous boolean DEFAULT false NOT NULL,
    supporter_id integer,
    origin_url text,
    manual boolean,
    campaign_id integer,
    recurring_donation_id integer,
    comment text,
    recurring boolean,
    dedication text,
    event_id integer,
    imported_at timestamp without time zone,
    charge_id integer,
    payment_id integer,
    category character varying(255),
    date timestamp without time zone,
    queued_for_import_at timestamp without time zone,
    direct_debit_detail_id integer,
    payment_provider character varying(255),
    fts tsvector
);


--
-- Name: donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.donations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.donations_id_seq OWNED BY public.donations.id;


--
-- Name: donations_payment_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.donations_payment_imports (
    donation_id integer,
    payment_import_id integer
);


--
-- Name: e_tap_import_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e_tap_import_contacts (
    id integer NOT NULL,
    e_tap_import_id integer,
    "row" jsonb,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: e_tap_import_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.e_tap_import_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: e_tap_import_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.e_tap_import_contacts_id_seq OWNED BY public.e_tap_import_contacts.id;


--
-- Name: e_tap_import_journal_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e_tap_import_journal_entries (
    id integer NOT NULL,
    e_tap_import_id integer,
    "row" jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: e_tap_import_journal_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.e_tap_import_journal_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: e_tap_import_journal_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.e_tap_import_journal_entries_id_seq OWNED BY public.e_tap_import_journal_entries.id;


--
-- Name: e_tap_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e_tap_imports (
    id integer NOT NULL,
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: e_tap_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.e_tap_imports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: e_tap_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.e_tap_imports_id_seq OWNED BY public.e_tap_imports.id;


--
-- Name: email_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_lists (
    id integer NOT NULL,
    nonprofit_id integer NOT NULL,
    tag_master_id integer NOT NULL,
    list_name character varying(255) NOT NULL,
    mailchimp_list_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_lists_id_seq OWNED BY public.email_lists.id;


--
-- Name: email_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_settings (
    id integer NOT NULL,
    user_id integer,
    nonprofit_id integer,
    notify_payments boolean,
    notify_campaigns boolean,
    notify_events boolean,
    notify_payouts boolean,
    notify_recurring_donations boolean
);


--
-- Name: email_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_settings_id_seq OWNED BY public.email_settings.id;


--
-- Name: event_discounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_discounts (
    id integer NOT NULL,
    name character varying(255),
    code character varying(255),
    event_id integer,
    percent integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: event_discounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_discounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_discounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_discounts_id_seq OWNED BY public.event_discounts.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    name character varying(255),
    tagline character varying(255),
    summary text,
    body text,
    latitude double precision,
    longitude double precision,
    location character varying(255),
    main_image character varying(255),
    background_image character varying(255),
    nonprofit_id integer,
    published boolean,
    slug character varying(255),
    total_raised integer,
    directions text,
    venue_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_id integer,
    city character varying(255),
    state_code character varying(255),
    address character varying(255),
    zip_code character varying(255),
    show_total_raised boolean DEFAULT false,
    show_total_count boolean DEFAULT false,
    hide_activity_feed boolean,
    hide_title boolean,
    deleted boolean DEFAULT false,
    receipt_message text,
    organizer_email character varying(255),
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: export_formats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.export_formats (
    id integer NOT NULL,
    name character varying NOT NULL,
    date_format character varying,
    show_currency boolean DEFAULT true NOT NULL,
    custom_columns_and_values jsonb,
    nonprofit_id integer NOT NULL
);


--
-- Name: export_formats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.export_formats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: export_formats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.export_formats_id_seq OWNED BY public.export_formats.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exports (
    id integer NOT NULL,
    user_id integer,
    nonprofit_id integer,
    status character varying(255),
    exception text,
    ended timestamp without time zone,
    export_type character varying(255),
    parameters text,
    url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exports_id_seq OWNED BY public.exports.id;


--
-- Name: fee_coverage_detail_bases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_coverage_detail_bases (
    id integer NOT NULL,
    flat_fee integer,
    percentage_fee numeric,
    dont_consider_billing_plan boolean DEFAULT false NOT NULL,
    fee_era_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fee_coverage_detail_bases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_coverage_detail_bases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_coverage_detail_bases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_coverage_detail_bases_id_seq OWNED BY public.fee_coverage_detail_bases.id;


--
-- Name: fee_eras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_eras (
    id integer NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    local_country character varying,
    international_surcharge_fee numeric,
    refund_stripe_fee boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fee_eras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_eras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_eras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_eras_id_seq OWNED BY public.fee_eras.id;


--
-- Name: fee_structures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_structures (
    id integer NOT NULL,
    brand character varying,
    flat_fee integer,
    stripe_fee numeric,
    fee_era_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fee_structures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_structures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_structures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_structures_id_seq OWNED BY public.fee_structures.id;


--
-- Name: full_contact_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.full_contact_infos (
    id integer NOT NULL,
    email character varying(255),
    full_name character varying(255),
    gender character varying(255),
    city character varying(255),
    county character varying(255),
    state_code character varying(255),
    country character varying(255),
    continent character varying(255),
    age character varying(255),
    age_range character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    supporter_id integer,
    location_general character varying(255),
    websites text
);


--
-- Name: full_contact_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.full_contact_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.full_contact_infos_id_seq OWNED BY public.full_contact_infos.id;


--
-- Name: full_contact_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.full_contact_jobs (
    id integer NOT NULL,
    supporter_id integer
);


--
-- Name: full_contact_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.full_contact_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.full_contact_jobs_id_seq OWNED BY public.full_contact_jobs.id;


--
-- Name: full_contact_orgs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.full_contact_orgs (
    id integer NOT NULL,
    is_primary boolean,
    name character varying(255),
    start_date date,
    end_date date,
    title character varying(255),
    current boolean,
    full_contact_info_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: full_contact_orgs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.full_contact_orgs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_orgs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.full_contact_orgs_id_seq OWNED BY public.full_contact_orgs.id;


--
-- Name: full_contact_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.full_contact_photos (
    id integer NOT NULL,
    full_contact_info_id integer,
    type_id character varying(255),
    is_primary boolean,
    url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: full_contact_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.full_contact_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.full_contact_photos_id_seq OWNED BY public.full_contact_photos.id;


--
-- Name: full_contact_social_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.full_contact_social_profiles (
    id integer NOT NULL,
    full_contact_info_id integer,
    type_id character varying(255),
    username character varying(255),
    uid character varying(255),
    bio text,
    url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    followers integer,
    following integer
);


--
-- Name: full_contact_social_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.full_contact_social_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_social_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.full_contact_social_profiles_id_seq OWNED BY public.full_contact_social_profiles.id;


--
-- Name: full_contact_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.full_contact_topics (
    id integer NOT NULL,
    provider character varying(255),
    value character varying(255),
    full_contact_info_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: full_contact_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.full_contact_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.full_contact_topics_id_seq OWNED BY public.full_contact_topics.id;


--
-- Name: image_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_attachments (
    id integer NOT NULL,
    file character varying(255),
    parent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_type character varying(255)
);


--
-- Name: image_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_attachments_id_seq OWNED BY public.image_attachments.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imports (
    id integer NOT NULL,
    row_count integer,
    date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    imported_count integer,
    nonprofit_id integer,
    user_id integer
);


--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imports_id_seq OWNED BY public.imports.id;


--
-- Name: journal_entries_to_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_entries_to_items (
    id integer NOT NULL,
    e_tap_import_journal_entry_id integer,
    item_id integer,
    item_type character varying
);


--
-- Name: journal_entries_to_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journal_entries_to_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_entries_to_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journal_entries_to_items_id_seq OWNED BY public.journal_entries_to_items.id;


--
-- Name: misc_campaign_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.misc_campaign_infos (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    campaign_id integer,
    manual_cover_fees boolean,
    hide_cover_fees_option boolean,
    paused boolean DEFAULT false NOT NULL
);


--
-- Name: misc_campaign_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.misc_campaign_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: misc_campaign_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.misc_campaign_infos_id_seq OWNED BY public.misc_campaign_infos.id;


--
-- Name: misc_event_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.misc_event_infos (
    id integer NOT NULL,
    event_id integer,
    hide_cover_fees_option boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    custom_get_tickets_button_label character varying
);


--
-- Name: misc_event_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.misc_event_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: misc_event_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.misc_event_infos_id_seq OWNED BY public.misc_event_infos.id;


--
-- Name: misc_payment_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.misc_payment_infos (
    id integer NOT NULL,
    payment_id integer,
    fee_covered boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: misc_payment_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.misc_payment_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: misc_payment_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.misc_payment_infos_id_seq OWNED BY public.misc_payment_infos.id;


--
-- Name: misc_recurring_donation_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.misc_recurring_donation_infos (
    id integer NOT NULL,
    recurring_donation_id integer,
    fee_covered boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: misc_recurring_donation_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.misc_recurring_donation_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: misc_recurring_donation_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.misc_recurring_donation_infos_id_seq OWNED BY public.misc_recurring_donation_infos.id;


--
-- Name: misc_refund_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.misc_refund_infos (
    id integer NOT NULL,
    is_modern boolean,
    stripe_application_fee_refund_id character varying(255),
    refund_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: misc_refund_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.misc_refund_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: misc_refund_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.misc_refund_infos_id_seq OWNED BY public.misc_refund_infos.id;


--
-- Name: miscellaneous_np_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.miscellaneous_np_infos (
    id integer NOT NULL,
    donate_again_url character varying(255),
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    change_amount_message text,
    first_charge_email_sent boolean,
    hide_cover_fees boolean DEFAULT false NOT NULL
);


--
-- Name: miscellaneous_np_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.miscellaneous_np_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: miscellaneous_np_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.miscellaneous_np_infos_id_seq OWNED BY public.miscellaneous_np_infos.id;


--
-- Name: nonprofit_deactivations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nonprofit_deactivations (
    id integer NOT NULL,
    nonprofit_id integer,
    deactivated boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nonprofit_deactivations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nonprofit_deactivations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nonprofit_deactivations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nonprofit_deactivations_id_seq OWNED BY public.nonprofit_deactivations.id;


--
-- Name: nonprofit_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nonprofit_keys (
    id integer NOT NULL,
    nonprofit_id integer,
    mailchimp_token text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nonprofit_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nonprofit_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nonprofit_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nonprofit_keys_id_seq OWNED BY public.nonprofit_keys.id;


--
-- Name: nonprofit_verification_backups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nonprofit_verification_backups (
    id integer NOT NULL,
    verification_status character varying(255)
);


--
-- Name: nonprofit_verification_backups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nonprofit_verification_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nonprofit_verification_backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nonprofit_verification_backups_id_seq OWNED BY public.nonprofit_verification_backups.id;


--
-- Name: nonprofit_verification_process_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nonprofit_verification_process_statuses (
    id integer NOT NULL,
    stripe_account_id character varying(255) NOT NULL,
    started_at timestamp without time zone,
    email_to_send_guid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nonprofit_verification_process_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nonprofit_verification_process_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nonprofit_verification_process_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nonprofit_verification_process_statuses_id_seq OWNED BY public.nonprofit_verification_process_statuses.id;


--
-- Name: nonprofits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nonprofits (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255),
    tagline character varying(255),
    phone character varying(255),
    email character varying(255),
    main_image character varying(255),
    second_image character varying(255),
    third_image character varying(255),
    website character varying(255),
    background_image character varying(255),
    logo character varying(255),
    summary text,
    categories text,
    ein character varying(255),
    full_description text,
    achievements text,
    state_code character varying(255),
    city character varying(255),
    slug character varying(255),
    published boolean,
    address text,
    vetted boolean,
    zip_code character varying(255),
    latitude double precision,
    longitude double precision,
    state_code_slug character varying(255),
    city_slug character varying(255),
    referrer character varying(255),
    thank_you_note text,
    no_anon boolean,
    timezone character varying(255),
    statement character varying(255),
    brand_color character varying(255),
    brand_font character varying(255),
    stripe_account_id character varying(255),
    hide_activity_feed boolean,
    tracking_script text DEFAULT ''::text,
    facebook character varying(255),
    twitter character varying(255),
    youtube character varying(255),
    instagram character varying(255),
    blog character varying(255),
    card_failure_message_top text,
    card_failure_message_bottom text,
    fields_needed text,
    autocomplete_supporter_address boolean DEFAULT false,
    currency character varying(255) DEFAULT 'usd'::character varying,
    feature_flag_autocomplete_supporter_address boolean DEFAULT false,
    houid character varying
);


--
-- Name: nonprofits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nonprofits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nonprofits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nonprofits_id_seq OWNED BY public.nonprofits.id;


--
-- Name: offsite_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offsite_payments (
    id integer NOT NULL,
    gross_amount integer,
    kind character varying(255),
    nonprofit_id integer,
    supporter_id integer,
    donation_id integer,
    payment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    date timestamp without time zone,
    check_number character varying(255),
    user_id integer
);


--
-- Name: offsite_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.offsite_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offsite_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.offsite_payments_id_seq OWNED BY public.offsite_payments.id;


--
-- Name: payment_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_imports (
    id integer NOT NULL,
    user_id integer,
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_imports_id_seq OWNED BY public.payment_imports.id;


--
-- Name: payment_payouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_payouts (
    id integer NOT NULL,
    donation_id integer,
    payout_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    total_fees integer,
    charge_id integer,
    payment_id integer
);


--
-- Name: payment_payouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_payouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_payouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_payouts_id_seq OWNED BY public.payment_payouts.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    gross_amount integer,
    refund_total integer DEFAULT 0,
    fee_total integer,
    net_amount integer,
    nonprofit_id integer,
    supporter_id integer,
    towards character varying(255),
    kind character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    donation_id integer,
    date timestamp without time zone
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: payouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payouts (
    id integer NOT NULL,
    net_amount integer,
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    failure_message character varying(255),
    status character varying(255),
    fee_total integer,
    gross_amount integer,
    bank_name character varying(255),
    email character varying(255),
    count integer,
    manual boolean,
    scheduled boolean,
    stripe_transfer_id character varying(255),
    user_ip character varying(255),
    ach_fee integer
);


--
-- Name: payouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payouts_id_seq OWNED BY public.payouts.id;


--
-- Name: periodic_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.periodic_reports (
    id integer NOT NULL,
    active boolean DEFAULT false NOT NULL,
    report_type character varying NOT NULL,
    period character varying NOT NULL,
    user_id integer,
    nonprofit_id integer
);


--
-- Name: periodic_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.periodic_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periodic_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.periodic_reports_id_seq OWNED BY public.periodic_reports.id;


--
-- Name: periodic_reports_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.periodic_reports_users (
    id integer NOT NULL,
    periodic_report_id integer,
    user_id integer
);


--
-- Name: periodic_reports_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.periodic_reports_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periodic_reports_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.periodic_reports_users_id_seq OWNED BY public.periodic_reports_users.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    admin_id integer,
    state_code character varying(255),
    city character varying(255),
    privacy_settings text,
    picture character varying(255),
    phone character varying(255),
    address character varying(255),
    anonymous boolean,
    zip_code character varying(255),
    total_recurring integer,
    first_name character varying(255),
    last_name character varying(255),
    mini_bio text,
    country character varying(255) DEFAULT 'US'::character varying
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


--
-- Name: reassignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reassignments (
    id integer NOT NULL,
    item_id integer,
    item_type character varying,
    e_tap_import_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_supporter_id integer,
    target_supporter_id integer
);


--
-- Name: reassignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reassignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reassignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reassignments_id_seq OWNED BY public.reassignments.id;


--
-- Name: recaptcha_rejections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recaptcha_rejections (
    id integer NOT NULL,
    details text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: recaptcha_rejections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recaptcha_rejections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recaptcha_rejections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recaptcha_rejections_id_seq OWNED BY public.recaptcha_rejections.id;


--
-- Name: recurring_donation_holds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurring_donation_holds (
    id integer NOT NULL,
    recurring_donation_id integer,
    end_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: recurring_donation_holds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurring_donation_holds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurring_donation_holds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurring_donation_holds_id_seq OWNED BY public.recurring_donation_holds.id;


--
-- Name: recurring_donations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurring_donations (
    id integer NOT NULL,
    active boolean,
    paydate integer,
    card_id integer,
    nonprofit_id integer,
    campaign_id integer,
    origin_url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_id integer,
    amount integer,
    supporter_id integer,
    email character varying(255),
    edit_token character varying(255),
    failure_message character varying(255),
    "interval" integer,
    time_unit character varying(255),
    start_date date,
    end_date date,
    anonymous boolean DEFAULT false NOT NULL,
    donation_id integer,
    n_failures integer,
    cancelled_by character varying(255),
    cancelled_at timestamp without time zone
);


--
-- Name: recurring_donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurring_donations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurring_donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurring_donations_id_seq OWNED BY public.recurring_donations.id;


--
-- Name: refunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refunds (
    id integer NOT NULL,
    amount integer,
    comment text,
    charge_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    stripe_refund_id character varying(255),
    reason character varying(255),
    disbursed boolean,
    user_id integer,
    payment_id integer
);


--
-- Name: refunds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refunds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refunds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refunds_id_seq OWNED BY public.refunds.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(255),
    user_id integer,
    host_id integer,
    host_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: source_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_tokens (
    token uuid NOT NULL,
    expiration timestamp without time zone,
    tokenizable_id integer,
    tokenizable_type character varying(255),
    event_id integer,
    max_uses integer DEFAULT 1,
    total_uses integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_accounts (
    id integer NOT NULL,
    stripe_account_id character varying(255) NOT NULL,
    object jsonb NOT NULL,
    charges_enabled boolean,
    payouts_enabled boolean,
    disabled_reason character varying(255),
    eventually_due jsonb,
    currently_due jsonb,
    past_due jsonb,
    pending_verification jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_accounts_id_seq OWNED BY public.stripe_accounts.id;


--
-- Name: stripe_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_charges (
    id integer NOT NULL,
    object jsonb NOT NULL,
    stripe_charge_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_charges_id_seq OWNED BY public.stripe_charges.id;


--
-- Name: stripe_disputes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_disputes (
    id integer NOT NULL,
    object jsonb,
    balance_transactions jsonb,
    stripe_dispute_id character varying(255),
    stripe_charge_id character varying(255),
    status character varying(255),
    reason character varying(255),
    net_change integer,
    amount integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    evidence_due_date timestamp without time zone,
    started_at timestamp without time zone
);


--
-- Name: stripe_disputes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_disputes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_disputes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_disputes_id_seq OWNED BY public.stripe_disputes.id;


--
-- Name: stripe_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_events (
    id integer NOT NULL,
    object_id character varying(255),
    event_id character varying(255),
    event_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_events_id_seq OWNED BY public.stripe_events.id;


--
-- Name: supporter_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supporter_addresses (
    id integer NOT NULL,
    address character varying,
    city character varying,
    zip_code character varying,
    state_code character varying,
    country character varying,
    deleted boolean DEFAULT false NOT NULL,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: supporter_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supporter_addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporter_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supporter_addresses_id_seq OWNED BY public.supporter_addresses.id;


--
-- Name: supporter_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supporter_emails (
    id integer NOT NULL,
    "to" text,
    "from" character varying(255),
    subject character varying(255),
    body text,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nonprofit_id integer,
    recipient_count integer,
    user_id integer,
    gmail_thread_id character varying(255)
);


--
-- Name: supporter_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supporter_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporter_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supporter_emails_id_seq OWNED BY public.supporter_emails.id;


--
-- Name: supporter_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supporter_notes (
    id integer NOT NULL,
    content text,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    deleted boolean DEFAULT false
);


--
-- Name: supporter_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supporter_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporter_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supporter_notes_id_seq OWNED BY public.supporter_notes.id;


--
-- Name: supporters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supporters (
    id integer NOT NULL,
    profile_id integer,
    nonprofit_id integer,
    fields text,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255),
    email character varying(255),
    phone character varying(255),
    address character varying(255),
    city character varying(255),
    state_code character varying(255),
    anonymous boolean DEFAULT false NOT NULL,
    zip_code character varying(255),
    latitude double precision,
    longitude double precision,
    full_contact_info_id integer,
    deleted boolean DEFAULT false,
    organization character varying(255),
    imported_at timestamp without time zone,
    country character varying(255) DEFAULT 'United States'::character varying,
    import_id integer,
    is_unsubscribed_from_emails boolean,
    merged_into integer,
    merged_at timestamp without time zone,
    region character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    locale character varying(255),
    fts tsvector,
    phone_index character varying,
    primary_address_id integer,
    houid character varying
);


--
-- Name: supporters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supporters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supporters_id_seq OWNED BY public.supporters.id;


--
-- Name: tag_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_joins (
    id integer NOT NULL,
    tag_master_id integer,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tag_joins_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_joins_backup (
    id integer NOT NULL,
    tag_master_id integer,
    supporter_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    metadata text
);


--
-- Name: tag_joins_backup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_joins_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_joins_backup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_joins_backup_id_seq OWNED BY public.tag_joins_backup.id;


--
-- Name: tag_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_joins_id_seq OWNED BY public.tag_joins.id;


--
-- Name: tag_masters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_masters (
    id integer NOT NULL,
    name character varying(255),
    nonprofit_id integer,
    deleted boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tag_masters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_masters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_masters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_masters_id_seq OWNED BY public.tag_masters.id;


--
-- Name: ticket_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_levels (
    id integer NOT NULL,
    event_id integer,
    amount integer,
    quantity integer,
    name character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted boolean DEFAULT false,
    "limit" integer,
    event_discount_id integer,
    admin_only boolean,
    "order" integer
);


--
-- Name: ticket_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_levels_id_seq OWNED BY public.ticket_levels.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    ticket_level_id integer,
    charge_id integer,
    profile_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    supporter_id integer,
    event_id integer,
    quantity integer,
    checked_in boolean,
    bid_id integer,
    card_id integer,
    payment_id integer,
    note text,
    event_discount_id integer,
    deleted boolean DEFAULT false,
    source_token_id uuid
);


--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: trackings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trackings (
    id integer NOT NULL,
    utm_campaign character varying(255),
    utm_medium character varying(255),
    utm_source character varying(255),
    donation_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    utm_content character varying(255)
);


--
-- Name: trackings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trackings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trackings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trackings_id_seq OWNED BY public.trackings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider character varying(255),
    uid character varying(255),
    user_id integer,
    token character varying(255),
    secret character varying(255),
    link character varying(255),
    name character varying(255),
    auto_generated boolean,
    referer integer,
    pending_password boolean,
    picture character varying(255),
    city character varying(255),
    state_code character varying(255),
    location character varying(255),
    latitude double precision,
    longitude double precision,
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    phone character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: bank_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts ALTER COLUMN id SET DEFAULT nextval('public.bank_accounts_id_seq'::regclass);


--
-- Name: billing_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_plans ALTER COLUMN id SET DEFAULT nextval('public.billing_plans_id_seq'::regclass);


--
-- Name: billing_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.billing_subscriptions_id_seq'::regclass);


--
-- Name: campaign_gift_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_gift_options ALTER COLUMN id SET DEFAULT nextval('public.campaign_gift_options_id_seq'::regclass);


--
-- Name: campaign_gifts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_gifts ALTER COLUMN id SET DEFAULT nextval('public.campaign_gifts_id_seq'::regclass);


--
-- Name: campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns ALTER COLUMN id SET DEFAULT nextval('public.campaigns_id_seq'::regclass);


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards ALTER COLUMN id SET DEFAULT nextval('public.cards_id_seq'::regclass);


--
-- Name: charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges ALTER COLUMN id SET DEFAULT nextval('public.charges_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: custom_field_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_joins ALTER COLUMN id SET DEFAULT nextval('public.custom_field_joins_id_seq'::regclass);


--
-- Name: custom_field_masters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_masters ALTER COLUMN id SET DEFAULT nextval('public.custom_field_masters_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: direct_debit_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.direct_debit_details ALTER COLUMN id SET DEFAULT nextval('public.direct_debit_details_id_seq'::regclass);


--
-- Name: dispute_payment_backups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispute_payment_backups ALTER COLUMN id SET DEFAULT nextval('public.dispute_payment_backups_id_seq'::regclass);


--
-- Name: dispute_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispute_transactions ALTER COLUMN id SET DEFAULT nextval('public.dispute_transactions_id_seq'::regclass);


--
-- Name: disputes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disputes ALTER COLUMN id SET DEFAULT nextval('public.disputes_id_seq'::regclass);


--
-- Name: donations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations ALTER COLUMN id SET DEFAULT nextval('public.donations_id_seq'::regclass);


--
-- Name: e_tap_import_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_tap_import_contacts ALTER COLUMN id SET DEFAULT nextval('public.e_tap_import_contacts_id_seq'::regclass);


--
-- Name: e_tap_import_journal_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_tap_import_journal_entries ALTER COLUMN id SET DEFAULT nextval('public.e_tap_import_journal_entries_id_seq'::regclass);


--
-- Name: e_tap_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_tap_imports ALTER COLUMN id SET DEFAULT nextval('public.e_tap_imports_id_seq'::regclass);


--
-- Name: email_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_lists ALTER COLUMN id SET DEFAULT nextval('public.email_lists_id_seq'::regclass);


--
-- Name: email_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_settings ALTER COLUMN id SET DEFAULT nextval('public.email_settings_id_seq'::regclass);


--
-- Name: event_discounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_discounts ALTER COLUMN id SET DEFAULT nextval('public.event_discounts_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: export_formats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_formats ALTER COLUMN id SET DEFAULT nextval('public.export_formats_id_seq'::regclass);


--
-- Name: exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports ALTER COLUMN id SET DEFAULT nextval('public.exports_id_seq'::regclass);


--
-- Name: fee_coverage_detail_bases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_coverage_detail_bases ALTER COLUMN id SET DEFAULT nextval('public.fee_coverage_detail_bases_id_seq'::regclass);


--
-- Name: fee_eras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_eras ALTER COLUMN id SET DEFAULT nextval('public.fee_eras_id_seq'::regclass);


--
-- Name: fee_structures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures ALTER COLUMN id SET DEFAULT nextval('public.fee_structures_id_seq'::regclass);


--
-- Name: full_contact_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_infos ALTER COLUMN id SET DEFAULT nextval('public.full_contact_infos_id_seq'::regclass);


--
-- Name: full_contact_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_jobs ALTER COLUMN id SET DEFAULT nextval('public.full_contact_jobs_id_seq'::regclass);


--
-- Name: full_contact_orgs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_orgs ALTER COLUMN id SET DEFAULT nextval('public.full_contact_orgs_id_seq'::regclass);


--
-- Name: full_contact_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_photos ALTER COLUMN id SET DEFAULT nextval('public.full_contact_photos_id_seq'::regclass);


--
-- Name: full_contact_social_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_social_profiles ALTER COLUMN id SET DEFAULT nextval('public.full_contact_social_profiles_id_seq'::regclass);


--
-- Name: full_contact_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_topics ALTER COLUMN id SET DEFAULT nextval('public.full_contact_topics_id_seq'::regclass);


--
-- Name: image_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_attachments ALTER COLUMN id SET DEFAULT nextval('public.image_attachments_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports ALTER COLUMN id SET DEFAULT nextval('public.imports_id_seq'::regclass);


--
-- Name: journal_entries_to_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries_to_items ALTER COLUMN id SET DEFAULT nextval('public.journal_entries_to_items_id_seq'::regclass);


--
-- Name: misc_campaign_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_campaign_infos ALTER COLUMN id SET DEFAULT nextval('public.misc_campaign_infos_id_seq'::regclass);


--
-- Name: misc_event_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_event_infos ALTER COLUMN id SET DEFAULT nextval('public.misc_event_infos_id_seq'::regclass);


--
-- Name: misc_payment_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_payment_infos ALTER COLUMN id SET DEFAULT nextval('public.misc_payment_infos_id_seq'::regclass);


--
-- Name: misc_recurring_donation_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_recurring_donation_infos ALTER COLUMN id SET DEFAULT nextval('public.misc_recurring_donation_infos_id_seq'::regclass);


--
-- Name: misc_refund_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_refund_infos ALTER COLUMN id SET DEFAULT nextval('public.misc_refund_infos_id_seq'::regclass);


--
-- Name: miscellaneous_np_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.miscellaneous_np_infos ALTER COLUMN id SET DEFAULT nextval('public.miscellaneous_np_infos_id_seq'::regclass);


--
-- Name: nonprofit_deactivations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_deactivations ALTER COLUMN id SET DEFAULT nextval('public.nonprofit_deactivations_id_seq'::regclass);


--
-- Name: nonprofit_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_keys ALTER COLUMN id SET DEFAULT nextval('public.nonprofit_keys_id_seq'::regclass);


--
-- Name: nonprofit_verification_backups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_verification_backups ALTER COLUMN id SET DEFAULT nextval('public.nonprofit_verification_backups_id_seq'::regclass);


--
-- Name: nonprofit_verification_process_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_verification_process_statuses ALTER COLUMN id SET DEFAULT nextval('public.nonprofit_verification_process_statuses_id_seq'::regclass);


--
-- Name: nonprofits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofits ALTER COLUMN id SET DEFAULT nextval('public.nonprofits_id_seq'::regclass);


--
-- Name: offsite_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offsite_payments ALTER COLUMN id SET DEFAULT nextval('public.offsite_payments_id_seq'::regclass);


--
-- Name: payment_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_imports ALTER COLUMN id SET DEFAULT nextval('public.payment_imports_id_seq'::regclass);


--
-- Name: payment_payouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_payouts ALTER COLUMN id SET DEFAULT nextval('public.payment_payouts_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: payouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts ALTER COLUMN id SET DEFAULT nextval('public.payouts_id_seq'::regclass);


--
-- Name: periodic_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_reports ALTER COLUMN id SET DEFAULT nextval('public.periodic_reports_id_seq'::regclass);


--
-- Name: periodic_reports_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_reports_users ALTER COLUMN id SET DEFAULT nextval('public.periodic_reports_users_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- Name: reassignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reassignments ALTER COLUMN id SET DEFAULT nextval('public.reassignments_id_seq'::regclass);


--
-- Name: recaptcha_rejections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recaptcha_rejections ALTER COLUMN id SET DEFAULT nextval('public.recaptcha_rejections_id_seq'::regclass);


--
-- Name: recurring_donation_holds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_donation_holds ALTER COLUMN id SET DEFAULT nextval('public.recurring_donation_holds_id_seq'::regclass);


--
-- Name: recurring_donations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_donations ALTER COLUMN id SET DEFAULT nextval('public.recurring_donations_id_seq'::regclass);


--
-- Name: refunds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds ALTER COLUMN id SET DEFAULT nextval('public.refunds_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: stripe_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_accounts ALTER COLUMN id SET DEFAULT nextval('public.stripe_accounts_id_seq'::regclass);


--
-- Name: stripe_charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_charges ALTER COLUMN id SET DEFAULT nextval('public.stripe_charges_id_seq'::regclass);


--
-- Name: stripe_disputes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_disputes ALTER COLUMN id SET DEFAULT nextval('public.stripe_disputes_id_seq'::regclass);


--
-- Name: stripe_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_events ALTER COLUMN id SET DEFAULT nextval('public.stripe_events_id_seq'::regclass);


--
-- Name: supporter_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporter_addresses ALTER COLUMN id SET DEFAULT nextval('public.supporter_addresses_id_seq'::regclass);


--
-- Name: supporter_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporter_emails ALTER COLUMN id SET DEFAULT nextval('public.supporter_emails_id_seq'::regclass);


--
-- Name: supporter_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporter_notes ALTER COLUMN id SET DEFAULT nextval('public.supporter_notes_id_seq'::regclass);


--
-- Name: supporters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporters ALTER COLUMN id SET DEFAULT nextval('public.supporters_id_seq'::regclass);


--
-- Name: tag_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_joins ALTER COLUMN id SET DEFAULT nextval('public.tag_joins_id_seq'::regclass);


--
-- Name: tag_joins_backup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_joins_backup ALTER COLUMN id SET DEFAULT nextval('public.tag_joins_backup_id_seq'::regclass);


--
-- Name: tag_masters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_masters ALTER COLUMN id SET DEFAULT nextval('public.tag_masters_id_seq'::regclass);


--
-- Name: ticket_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_levels ALTER COLUMN id SET DEFAULT nextval('public.ticket_levels_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: trackings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trackings ALTER COLUMN id SET DEFAULT nextval('public.trackings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: billing_plans billing_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_plans
    ADD CONSTRAINT billing_plan_pkey PRIMARY KEY (id);


--
-- Name: billing_subscriptions billing_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_subscriptions
    ADD CONSTRAINT billing_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: activities campaign_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT campaign_activities_pkey PRIMARY KEY (id);


--
-- Name: comments campaign_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT campaign_comments_pkey PRIMARY KEY (id);


--
-- Name: campaign_gift_options campaign_gift_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_gift_options
    ADD CONSTRAINT campaign_gift_options_pkey PRIMARY KEY (id);


--
-- Name: campaign_gifts campaign_gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_gifts
    ADD CONSTRAINT campaign_gifts_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: charges charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges
    ADD CONSTRAINT charges_pkey PRIMARY KEY (id);


--
-- Name: custom_field_joins custom_field_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_joins
    ADD CONSTRAINT custom_field_joins_pkey PRIMARY KEY (id);


--
-- Name: custom_field_masters custom_field_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_masters
    ADD CONSTRAINT custom_field_masters_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: direct_debit_details direct_debit_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.direct_debit_details
    ADD CONSTRAINT direct_debit_details_pkey PRIMARY KEY (id);


--
-- Name: dispute_payment_backups dispute_payment_backups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispute_payment_backups
    ADD CONSTRAINT dispute_payment_backups_pkey PRIMARY KEY (id);


--
-- Name: dispute_transactions dispute_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispute_transactions
    ADD CONSTRAINT dispute_transactions_pkey PRIMARY KEY (id);


--
-- Name: disputes disputes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disputes
    ADD CONSTRAINT disputes_pkey PRIMARY KEY (id);


--
-- Name: payment_payouts donation_disbursals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_payouts
    ADD CONSTRAINT donation_disbursals_pkey PRIMARY KEY (id);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (id);


--
-- Name: profiles donor_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT donor_profiles_pkey PRIMARY KEY (id);


--
-- Name: e_tap_import_contacts e_tap_import_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_tap_import_contacts
    ADD CONSTRAINT e_tap_import_contacts_pkey PRIMARY KEY (id);


--
-- Name: e_tap_import_journal_entries e_tap_import_journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_tap_import_journal_entries
    ADD CONSTRAINT e_tap_import_journal_entries_pkey PRIMARY KEY (id);


--
-- Name: e_tap_imports e_tap_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_tap_imports
    ADD CONSTRAINT e_tap_imports_pkey PRIMARY KEY (id);


--
-- Name: email_settings email_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_settings
    ADD CONSTRAINT email_settings_pkey PRIMARY KEY (id);


--
-- Name: event_discounts event_discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_discounts
    ADD CONSTRAINT event_discounts_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: export_formats export_formats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_formats
    ADD CONSTRAINT export_formats_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: fee_coverage_detail_bases fee_coverage_detail_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_coverage_detail_bases
    ADD CONSTRAINT fee_coverage_detail_bases_pkey PRIMARY KEY (id);


--
-- Name: fee_eras fee_eras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_eras
    ADD CONSTRAINT fee_eras_pkey PRIMARY KEY (id);


--
-- Name: fee_structures fee_structures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fee_structures_pkey PRIMARY KEY (id);


--
-- Name: full_contact_infos full_contact_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_infos
    ADD CONSTRAINT full_contact_infos_pkey PRIMARY KEY (id);


--
-- Name: full_contact_jobs full_contact_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_jobs
    ADD CONSTRAINT full_contact_jobs_pkey PRIMARY KEY (id);


--
-- Name: full_contact_orgs full_contact_orgs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_orgs
    ADD CONSTRAINT full_contact_orgs_pkey PRIMARY KEY (id);


--
-- Name: full_contact_photos full_contact_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_photos
    ADD CONSTRAINT full_contact_photos_pkey PRIMARY KEY (id);


--
-- Name: full_contact_social_profiles full_contact_social_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_social_profiles
    ADD CONSTRAINT full_contact_social_profiles_pkey PRIMARY KEY (id);


--
-- Name: full_contact_topics full_contact_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_contact_topics
    ADD CONSTRAINT full_contact_topics_pkey PRIMARY KEY (id);


--
-- Name: image_attachments image_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_attachments
    ADD CONSTRAINT image_attachments_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: journal_entries_to_items journal_entries_to_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries_to_items
    ADD CONSTRAINT journal_entries_to_items_pkey PRIMARY KEY (id);


--
-- Name: email_lists mailchimp_email_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_lists
    ADD CONSTRAINT mailchimp_email_lists_pkey PRIMARY KEY (id);


--
-- Name: misc_campaign_infos misc_campaign_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_campaign_infos
    ADD CONSTRAINT misc_campaign_infos_pkey PRIMARY KEY (id);


--
-- Name: misc_event_infos misc_event_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_event_infos
    ADD CONSTRAINT misc_event_infos_pkey PRIMARY KEY (id);


--
-- Name: misc_payment_infos misc_payment_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_payment_infos
    ADD CONSTRAINT misc_payment_infos_pkey PRIMARY KEY (id);


--
-- Name: misc_recurring_donation_infos misc_recurring_donation_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_recurring_donation_infos
    ADD CONSTRAINT misc_recurring_donation_infos_pkey PRIMARY KEY (id);


--
-- Name: misc_refund_infos misc_refund_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.misc_refund_infos
    ADD CONSTRAINT misc_refund_infos_pkey PRIMARY KEY (id);


--
-- Name: miscellaneous_np_infos miscellaneous_np_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.miscellaneous_np_infos
    ADD CONSTRAINT miscellaneous_np_infos_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts nonprofit_bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT nonprofit_bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: payouts nonprofit_credits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT nonprofit_credits_pkey PRIMARY KEY (id);


--
-- Name: nonprofit_deactivations nonprofit_deactivations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_deactivations
    ADD CONSTRAINT nonprofit_deactivations_pkey PRIMARY KEY (id);


--
-- Name: nonprofit_keys nonprofit_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_keys
    ADD CONSTRAINT nonprofit_keys_pkey PRIMARY KEY (id);


--
-- Name: nonprofit_verification_backups nonprofit_verification_backups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_verification_backups
    ADD CONSTRAINT nonprofit_verification_backups_pkey PRIMARY KEY (id);


--
-- Name: nonprofit_verification_process_statuses nonprofit_verification_process_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofit_verification_process_statuses
    ADD CONSTRAINT nonprofit_verification_process_statuses_pkey PRIMARY KEY (id);


--
-- Name: nonprofits npos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nonprofits
    ADD CONSTRAINT npos_pkey PRIMARY KEY (id);


--
-- Name: offsite_payments offsite_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offsite_payments
    ADD CONSTRAINT offsite_payments_pkey PRIMARY KEY (id);


--
-- Name: payment_imports payment_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_imports
    ADD CONSTRAINT payment_imports_pkey PRIMARY KEY (id);


--
-- Name: cards payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: periodic_reports periodic_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_reports
    ADD CONSTRAINT periodic_reports_pkey PRIMARY KEY (id);


--
-- Name: periodic_reports_users periodic_reports_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_reports_users
    ADD CONSTRAINT periodic_reports_users_pkey PRIMARY KEY (id);


--
-- Name: reassignments reassignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reassignments
    ADD CONSTRAINT reassignments_pkey PRIMARY KEY (id);


--
-- Name: recaptcha_rejections recaptcha_rejections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recaptcha_rejections
    ADD CONSTRAINT recaptcha_rejections_pkey PRIMARY KEY (id);


--
-- Name: recurring_donation_holds recurring_donation_holds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_donation_holds
    ADD CONSTRAINT recurring_donation_holds_pkey PRIMARY KEY (id);


--
-- Name: recurring_donations recurring_donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_donations
    ADD CONSTRAINT recurring_donations_pkey PRIMARY KEY (id);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: stripe_accounts stripe_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_accounts
    ADD CONSTRAINT stripe_accounts_pkey PRIMARY KEY (id);


--
-- Name: stripe_charges stripe_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_charges
    ADD CONSTRAINT stripe_charges_pkey PRIMARY KEY (id);


--
-- Name: stripe_disputes stripe_disputes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_disputes
    ADD CONSTRAINT stripe_disputes_pkey PRIMARY KEY (id);


--
-- Name: stripe_events stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- Name: supporter_addresses supporter_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporter_addresses
    ADD CONSTRAINT supporter_addresses_pkey PRIMARY KEY (id);


--
-- Name: supporters supporter_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporters
    ADD CONSTRAINT supporter_data_pkey PRIMARY KEY (id);


--
-- Name: supporter_emails supporter_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporter_emails
    ADD CONSTRAINT supporter_emails_pkey PRIMARY KEY (id);


--
-- Name: supporter_notes supporter_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporter_notes
    ADD CONSTRAINT supporter_notes_pkey PRIMARY KEY (id);


--
-- Name: tag_joins_backup tag_joins_backup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_joins_backup
    ADD CONSTRAINT tag_joins_backup_pkey PRIMARY KEY (id);


--
-- Name: tag_joins tag_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_joins
    ADD CONSTRAINT tag_joins_pkey PRIMARY KEY (id);


--
-- Name: tag_masters tag_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_masters
    ADD CONSTRAINT tag_masters_pkey PRIMARY KEY (id);


--
-- Name: ticket_levels ticket_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_levels
    ADD CONSTRAINT ticket_levels_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: trackings trackings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trackings
    ADD CONSTRAINT trackings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: custom_field_join_supporter_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX custom_field_join_supporter_unique_idx ON public.custom_field_joins USING btree (custom_field_master_id, supporter_id);


--
-- Name: custom_field_joins_custom_field_master_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX custom_field_joins_custom_field_master_id ON public.custom_field_joins USING btree (custom_field_master_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: donations_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_amount ON public.donations USING btree (amount);


--
-- Name: donations_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_campaign_id ON public.donations USING btree (campaign_id);


--
-- Name: donations_designation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_designation ON public.donations USING btree (lower(designation));


--
-- Name: donations_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_event_id ON public.donations USING btree (event_id);


--
-- Name: donations_fts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_fts_idx ON public.donations USING gin (fts);


--
-- Name: donations_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_supporter_id ON public.donations USING btree (supporter_id);


--
-- Name: events_nonprofit_id_not_deleted_and_published_endtime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_nonprofit_id_not_deleted_and_published_endtime ON public.events USING btree (nonprofit_id, deleted, published, end_datetime);


--
-- Name: index_activities_on_attachment_type_and_attachment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_attachment_type_and_attachment_id ON public.activities USING btree (attachment_type, attachment_id);


--
-- Name: index_activities_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_nonprofit_id ON public.activities USING btree (nonprofit_id);


--
-- Name: index_activities_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_supporter_id ON public.activities USING btree (supporter_id);


--
-- Name: index_billing_subscriptions_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_subscriptions_on_nonprofit_id ON public.billing_subscriptions USING btree (nonprofit_id);


--
-- Name: index_billing_subscriptions_on_nonprofit_id_and_billing_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_subscriptions_on_nonprofit_id_and_billing_plan_id ON public.billing_subscriptions USING btree (nonprofit_id, billing_plan_id);


--
-- Name: index_campaign_gifts_on_campaign_gift_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_campaign_gifts_on_campaign_gift_option_id ON public.campaign_gifts USING btree (campaign_gift_option_id);


--
-- Name: index_campaign_gifts_on_donation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_campaign_gifts_on_donation_id ON public.campaign_gifts USING btree (donation_id);


--
-- Name: index_campaigns_on_parent_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_campaigns_on_parent_campaign_id ON public.campaigns USING btree (parent_campaign_id);


--
-- Name: index_cards_on_holder_id_and_holder_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_holder_id_and_holder_type ON public.cards USING btree (holder_id, holder_type);


--
-- Name: index_cards_on_id_and_holder_type_and_holder_id_and_inactive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_id_and_holder_type_and_holder_id_and_inactive ON public.cards USING btree (id, holder_type, holder_id, inactive);


--
-- Name: index_charges_on_donation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_donation_id ON public.charges USING btree (donation_id);


--
-- Name: index_charges_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_payment_id ON public.charges USING btree (payment_id);


--
-- Name: index_custom_field_joins_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_field_joins_on_supporter_id ON public.custom_field_joins USING btree (supporter_id);


--
-- Name: index_custom_field_masters_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_field_masters_on_nonprofit_id ON public.custom_field_masters USING btree (nonprofit_id);


--
-- Name: index_dispute_transactions_on_dispute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dispute_transactions_on_dispute_id ON public.dispute_transactions USING btree (dispute_id);


--
-- Name: index_dispute_transactions_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dispute_transactions_on_payment_id ON public.dispute_transactions USING btree (payment_id);


--
-- Name: index_disputes_on_stripe_dispute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_disputes_on_stripe_dispute_id ON public.disputes USING btree (stripe_dispute_id);


--
-- Name: index_donations_on_anonymous; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_donations_on_anonymous ON public.donations USING btree (anonymous);


--
-- Name: index_donations_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_donations_on_event_id ON public.donations USING btree (event_id);


--
-- Name: index_donations_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_donations_on_nonprofit_id ON public.donations USING btree (nonprofit_id);


--
-- Name: index_e_tap_import_contacts_on_e_tap_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_e_tap_import_contacts_on_e_tap_import_id ON public.e_tap_import_contacts USING btree (e_tap_import_id);


--
-- Name: index_e_tap_import_contacts_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_e_tap_import_contacts_on_supporter_id ON public.e_tap_import_contacts USING btree (supporter_id);


--
-- Name: index_e_tap_import_journal_entries_on_e_tap_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_e_tap_import_journal_entries_on_e_tap_import_id ON public.e_tap_import_journal_entries USING btree (e_tap_import_id);


--
-- Name: index_events_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_nonprofit_id ON public.events USING btree (nonprofit_id);


--
-- Name: index_events_on_nonprofit_id_and_deleted_and_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_nonprofit_id_and_deleted_and_published ON public.events USING btree (nonprofit_id, deleted, published);


--
-- Name: index_export_formats_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_export_formats_on_nonprofit_id ON public.export_formats USING btree (nonprofit_id);


--
-- Name: index_exports_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_nonprofit_id ON public.exports USING btree (nonprofit_id);


--
-- Name: index_exports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_user_id ON public.exports USING btree (user_id);


--
-- Name: index_full_contact_infos_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_full_contact_infos_on_supporter_id ON public.full_contact_infos USING btree (supporter_id);


--
-- Name: index_full_contact_orgs_on_full_contact_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_full_contact_orgs_on_full_contact_info_id ON public.full_contact_orgs USING btree (full_contact_info_id);


--
-- Name: index_full_contact_social_profiles_on_full_contact_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_full_contact_social_profiles_on_full_contact_info_id ON public.full_contact_social_profiles USING btree (full_contact_info_id);


--
-- Name: index_full_contact_topics_on_full_contact_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_full_contact_topics_on_full_contact_info_id ON public.full_contact_topics USING btree (full_contact_info_id);


--
-- Name: index_full_context_photo_info_primary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_full_context_photo_info_primary ON public.full_contact_photos USING btree (full_contact_info_id, is_primary);


--
-- Name: index_misc_campaign_infos_on_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_misc_campaign_infos_on_campaign_id ON public.misc_campaign_infos USING btree (campaign_id);


--
-- Name: index_misc_payment_infos_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_misc_payment_infos_on_payment_id ON public.misc_payment_infos USING btree (payment_id);


--
-- Name: index_misc_recurring_donation_infos_on_recurring_donation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_misc_recurring_donation_infos_on_recurring_donation_id ON public.misc_recurring_donation_infos USING btree (recurring_donation_id);


--
-- Name: index_nonprofit_verification_to_stripe; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_nonprofit_verification_to_stripe ON public.nonprofit_verification_process_statuses USING btree (stripe_account_id);


--
-- Name: index_offsite_payments_on_check_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offsite_payments_on_check_number ON public.offsite_payments USING btree (check_number);


--
-- Name: index_offsite_payments_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offsite_payments_on_payment_id ON public.offsite_payments USING btree (payment_id);


--
-- Name: index_offsite_payments_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offsite_payments_on_supporter_id ON public.offsite_payments USING btree (supporter_id);


--
-- Name: index_periodic_reports_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_periodic_reports_on_nonprofit_id ON public.periodic_reports USING btree (nonprofit_id);


--
-- Name: index_periodic_reports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_periodic_reports_on_user_id ON public.periodic_reports USING btree (user_id);


--
-- Name: index_reassignments_on_e_tap_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reassignments_on_e_tap_import_id ON public.reassignments USING btree (e_tap_import_id);


--
-- Name: index_recurring_donations_on_donation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recurring_donations_on_donation_id ON public.recurring_donations USING btree (donation_id);


--
-- Name: index_recurring_donations_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recurring_donations_on_supporter_id ON public.recurring_donations USING btree (supporter_id);


--
-- Name: index_refunds_on_charge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_refunds_on_charge_id ON public.refunds USING btree (charge_id);


--
-- Name: index_refunds_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_refunds_on_payment_id ON public.refunds USING btree (payment_id);


--
-- Name: index_roles_on_name_and_user_id_and_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name_and_user_id_and_host_id ON public.roles USING btree (name, user_id, host_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_source_tokens_on_expiration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_source_tokens_on_expiration ON public.source_tokens USING btree (expiration);


--
-- Name: index_source_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_source_tokens_on_token ON public.source_tokens USING btree (token);


--
-- Name: index_source_tokens_on_tokenizable_id_and_tokenizable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_source_tokens_on_tokenizable_id_and_tokenizable_type ON public.source_tokens USING btree (tokenizable_id, tokenizable_type);


--
-- Name: index_stripe_accounts_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_accounts_on_id ON public.stripe_accounts USING btree (id);


--
-- Name: index_stripe_accounts_on_stripe_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_accounts_on_stripe_account_id ON public.stripe_accounts USING btree (stripe_account_id);


--
-- Name: index_stripe_charges_on_stripe_charge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_charges_on_stripe_charge_id ON public.stripe_charges USING btree (stripe_charge_id);


--
-- Name: index_stripe_disputes_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_disputes_on_id ON public.stripe_disputes USING btree (id);


--
-- Name: index_stripe_disputes_on_stripe_charge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_disputes_on_stripe_charge_id ON public.stripe_disputes USING btree (stripe_charge_id);


--
-- Name: index_stripe_disputes_on_stripe_dispute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_disputes_on_stripe_dispute_id ON public.stripe_disputes USING btree (stripe_dispute_id);


--
-- Name: index_stripe_events_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_event_id ON public.stripe_events USING btree (event_id);


--
-- Name: index_stripe_events_on_object_id_and_event_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_object_id_and_event_time ON public.stripe_events USING btree (object_id, event_time);


--
-- Name: index_supporter_addresses_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporter_addresses_on_supporter_id ON public.supporter_addresses USING btree (supporter_id);


--
-- Name: index_supporter_notes_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporter_notes_on_supporter_id ON public.supporter_notes USING btree (supporter_id);


--
-- Name: index_supporters_on_anonymous_and_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporters_on_anonymous_and_nonprofit_id ON public.supporters USING btree (anonymous, nonprofit_id);


--
-- Name: index_supporters_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporters_on_name ON public.supporters USING btree (name);


--
-- Name: index_supporters_on_nonprofit_id_and_imported_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporters_on_nonprofit_id_and_imported_at ON public.supporters USING btree (nonprofit_id, imported_at);


--
-- Name: index_supporters_on_nonprofit_id_and_phone_index_and_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporters_on_nonprofit_id_and_phone_index_and_deleted ON public.supporters USING btree (nonprofit_id, phone_index, deleted) WHERE ((phone IS NOT NULL) AND ((phone)::text <> ''::text));


--
-- Name: index_tag_joins_on_tag_master_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_joins_on_tag_master_id ON public.tag_joins USING btree (tag_master_id);


--
-- Name: index_tickets_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_event_id ON public.tickets USING btree (event_id);


--
-- Name: index_tickets_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_payment_id ON public.tickets USING btree (payment_id);


--
-- Name: index_tickets_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_supporter_id ON public.tickets USING btree (supporter_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: payments_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_date ON public.payments USING btree (date);


--
-- Name: payments_donation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_donation_id ON public.payments USING btree (donation_id);


--
-- Name: payments_gross_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_gross_amount ON public.payments USING btree (gross_amount);


--
-- Name: payments_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_kind ON public.payments USING btree (kind);


--
-- Name: payments_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_nonprofit_id ON public.payments USING btree (nonprofit_id);


--
-- Name: payments_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_supporter_id ON public.payments USING btree (supporter_id);


--
-- Name: supporters_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_email ON public.supporters USING btree (lower((email)::text)) WHERE (deleted <> true);


--
-- Name: supporters_fts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_fts_idx ON public.supporters USING gin (fts);


--
-- Name: supporters_general_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_general_idx ON public.supporters USING gin (to_tsvector('english'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || (COALESCE(email, ''::character varying))::text)));


--
-- Name: supporters_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_lower_name ON public.supporters USING btree (lower((name)::text)) WHERE (deleted <> true);


--
-- Name: supporters_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_nonprofit_id ON public.supporters USING btree (nonprofit_id) WHERE (deleted <> true);


--
-- Name: supporters_nonprofit_id_not_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_nonprofit_id_not_deleted ON public.supporters USING btree (nonprofit_id, deleted) WHERE (NOT deleted);


--
-- Name: tag_join_supporter_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tag_join_supporter_unique_idx ON public.tag_joins USING btree (tag_master_id, supporter_id);


--
-- Name: tag_joins_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tag_joins_supporter_id ON public.tag_joins USING btree (supporter_id);


--
-- Name: tag_joins_tag_master_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tag_joins_tag_master_id ON public.tag_joins USING btree (tag_master_id);


--
-- Name: tag_masters_nonprofit_id_not_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tag_masters_nonprofit_id_not_deleted ON public.tag_masters USING btree (nonprofit_id, deleted) WHERE (NOT deleted);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: donations update_donations_fts; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_donations_fts BEFORE INSERT OR UPDATE ON public.donations FOR EACH ROW EXECUTE FUNCTION public.update_fts_on_donations();


--
-- Name: supporters update_supporters_fts; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_supporters_fts BEFORE INSERT OR UPDATE ON public.supporters FOR EACH ROW EXECUTE FUNCTION public.update_fts_on_supporters();


--
-- Name: supporters update_supporters_phone_index; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_supporters_phone_index BEFORE INSERT OR UPDATE ON public.supporters FOR EACH ROW EXECUTE FUNCTION public.update_phone_index_on_supporters();


--
-- Name: campaign_gifts campaign_gifts_to_option_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_gifts
    ADD CONSTRAINT campaign_gifts_to_option_fk FOREIGN KEY (campaign_gift_option_id) REFERENCES public.campaign_gift_options(id);


--
-- Name: fee_coverage_detail_bases fk_rails_13c8ce7956; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_coverage_detail_bases
    ADD CONSTRAINT fk_rails_13c8ce7956 FOREIGN KEY (fee_era_id) REFERENCES public.fee_eras(id);


--
-- Name: fee_structures fk_rails_55f7b67177; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fk_rails_55f7b67177 FOREIGN KEY (fee_era_id) REFERENCES public.fee_eras(id);


--
-- Name: periodic_reports fk_rails_8f03e9aed1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_reports
    ADD CONSTRAINT fk_rails_8f03e9aed1 FOREIGN KEY (nonprofit_id) REFERENCES public.nonprofits(id);


--
-- Name: supporter_addresses fk_rails_bd7fbee619; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporter_addresses
    ADD CONSTRAINT fk_rails_bd7fbee619 FOREIGN KEY (supporter_id) REFERENCES public.supporters(id);


--
-- Name: periodic_reports fk_rails_d5610dd8f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_reports
    ADD CONSTRAINT fk_rails_d5610dd8f8 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: export_formats fk_rails_f7fae488f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_formats
    ADD CONSTRAINT fk_rails_f7fae488f3 FOREIGN KEY (nonprofit_id) REFERENCES public.nonprofits(id);


--
-- Name: payments payments_supporter_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_supporter_fk FOREIGN KEY (supporter_id) REFERENCES public.supporters(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20121003222211');

INSERT INTO schema_migrations (version) VALUES ('20121004001526');

INSERT INTO schema_migrations (version) VALUES ('20121004001607');

INSERT INTO schema_migrations (version) VALUES ('20121015223512');

INSERT INTO schema_migrations (version) VALUES ('20121015225020');

INSERT INTO schema_migrations (version) VALUES ('20121015225910');

INSERT INTO schema_migrations (version) VALUES ('20121019213735');

INSERT INTO schema_migrations (version) VALUES ('20121022182542');

INSERT INTO schema_migrations (version) VALUES ('20121022204042');

INSERT INTO schema_migrations (version) VALUES ('20121022213432');

INSERT INTO schema_migrations (version) VALUES ('20121022221555');

INSERT INTO schema_migrations (version) VALUES ('20121022223847');

INSERT INTO schema_migrations (version) VALUES ('20121024195047');

INSERT INTO schema_migrations (version) VALUES ('20121024195915');

INSERT INTO schema_migrations (version) VALUES ('20121025034330');

INSERT INTO schema_migrations (version) VALUES ('20121025221156');

INSERT INTO schema_migrations (version) VALUES ('20121030222057');

INSERT INTO schema_migrations (version) VALUES ('20121105191635');

INSERT INTO schema_migrations (version) VALUES ('20121106221754');

INSERT INTO schema_migrations (version) VALUES ('20121108210352');

INSERT INTO schema_migrations (version) VALUES ('20121108234416');

INSERT INTO schema_migrations (version) VALUES ('20121114005715');

INSERT INTO schema_migrations (version) VALUES ('20121114043837');

INSERT INTO schema_migrations (version) VALUES ('20121115215133');

INSERT INTO schema_migrations (version) VALUES ('20121116005335');

INSERT INTO schema_migrations (version) VALUES ('20121116225531');

INSERT INTO schema_migrations (version) VALUES ('20121118225834');

INSERT INTO schema_migrations (version) VALUES ('20121118230448');

INSERT INTO schema_migrations (version) VALUES ('20121118232034');

INSERT INTO schema_migrations (version) VALUES ('20121118232459');

INSERT INTO schema_migrations (version) VALUES ('20121119000932');

INSERT INTO schema_migrations (version) VALUES ('20121119001047');

INSERT INTO schema_migrations (version) VALUES ('20121119230540');

INSERT INTO schema_migrations (version) VALUES ('20121121040733');

INSERT INTO schema_migrations (version) VALUES ('20121128232717');

INSERT INTO schema_migrations (version) VALUES ('20121129204251');

INSERT INTO schema_migrations (version) VALUES ('20121129204327');

INSERT INTO schema_migrations (version) VALUES ('20121129212056');

INSERT INTO schema_migrations (version) VALUES ('20121129214734');

INSERT INTO schema_migrations (version) VALUES ('20121204182359');

INSERT INTO schema_migrations (version) VALUES ('20121214222749');

INSERT INTO schema_migrations (version) VALUES ('20130101221516');

INSERT INTO schema_migrations (version) VALUES ('20130118185608');

INSERT INTO schema_migrations (version) VALUES ('20130118193956');

INSERT INTO schema_migrations (version) VALUES ('20130201000156');

INSERT INTO schema_migrations (version) VALUES ('20130201231912');

INSERT INTO schema_migrations (version) VALUES ('20130219181314');

INSERT INTO schema_migrations (version) VALUES ('20130219182055');

INSERT INTO schema_migrations (version) VALUES ('20130220230448');

INSERT INTO schema_migrations (version) VALUES ('20130223012349');

INSERT INTO schema_migrations (version) VALUES ('20130226063123');

INSERT INTO schema_migrations (version) VALUES ('20130227000816');

INSERT INTO schema_migrations (version) VALUES ('20130227003421');

INSERT INTO schema_migrations (version) VALUES ('20130227003553');

INSERT INTO schema_migrations (version) VALUES ('20130227004016');

INSERT INTO schema_migrations (version) VALUES ('20130228043355');

INSERT INTO schema_migrations (version) VALUES ('20130302042515');

INSERT INTO schema_migrations (version) VALUES ('20130310042813');

INSERT INTO schema_migrations (version) VALUES ('20130312001712');

INSERT INTO schema_migrations (version) VALUES ('20130312044632');

INSERT INTO schema_migrations (version) VALUES ('20130314210510');

INSERT INTO schema_migrations (version) VALUES ('20130321212034');

INSERT INTO schema_migrations (version) VALUES ('20130324021734');

INSERT INTO schema_migrations (version) VALUES ('20130325225405');

INSERT INTO schema_migrations (version) VALUES ('20130401213946');

INSERT INTO schema_migrations (version) VALUES ('20130402014034');

INSERT INTO schema_migrations (version) VALUES ('20130416220113');

INSERT INTO schema_migrations (version) VALUES ('20130417170420');

INSERT INTO schema_migrations (version) VALUES ('20130417171255');

INSERT INTO schema_migrations (version) VALUES ('20130417234751');

INSERT INTO schema_migrations (version) VALUES ('20130418032103');

INSERT INTO schema_migrations (version) VALUES ('20130422160944');

INSERT INTO schema_migrations (version) VALUES ('20130423232208');

INSERT INTO schema_migrations (version) VALUES ('20130423233612');

INSERT INTO schema_migrations (version) VALUES ('20130521054001');

INSERT INTO schema_migrations (version) VALUES ('20130523211240');

INSERT INTO schema_migrations (version) VALUES ('20130625231648');

INSERT INTO schema_migrations (version) VALUES ('20130625233230');

INSERT INTO schema_migrations (version) VALUES ('20130627020419');

INSERT INTO schema_migrations (version) VALUES ('20130627021950');

INSERT INTO schema_migrations (version) VALUES ('20130628020316');

INSERT INTO schema_migrations (version) VALUES ('20130628025232');

INSERT INTO schema_migrations (version) VALUES ('20130701053605');

INSERT INTO schema_migrations (version) VALUES ('20130701054130');

INSERT INTO schema_migrations (version) VALUES ('20130703213155');

INSERT INTO schema_migrations (version) VALUES ('20130703213855');

INSERT INTO schema_migrations (version) VALUES ('20130704025623');

INSERT INTO schema_migrations (version) VALUES ('20130707005204');

INSERT INTO schema_migrations (version) VALUES ('20130708194147');

INSERT INTO schema_migrations (version) VALUES ('20130712164932');

INSERT INTO schema_migrations (version) VALUES ('20130717063816');

INSERT INTO schema_migrations (version) VALUES ('20130723060724');

INSERT INTO schema_migrations (version) VALUES ('20130730052924');

INSERT INTO schema_migrations (version) VALUES ('20130730231739');

INSERT INTO schema_migrations (version) VALUES ('20130730234913');

INSERT INTO schema_migrations (version) VALUES ('20130731030605');

INSERT INTO schema_migrations (version) VALUES ('20130731213414');

INSERT INTO schema_migrations (version) VALUES ('20130801060524');

INSERT INTO schema_migrations (version) VALUES ('20130802144119');

INSERT INTO schema_migrations (version) VALUES ('20130803034617');

INSERT INTO schema_migrations (version) VALUES ('20130805003250');

INSERT INTO schema_migrations (version) VALUES ('20130805204823');

INSERT INTO schema_migrations (version) VALUES ('20130814223517');

INSERT INTO schema_migrations (version) VALUES ('20130814225735');

INSERT INTO schema_migrations (version) VALUES ('20130816233808');

INSERT INTO schema_migrations (version) VALUES ('20130818060137');

INSERT INTO schema_migrations (version) VALUES ('20130818190900');

INSERT INTO schema_migrations (version) VALUES ('20130818235825');

INSERT INTO schema_migrations (version) VALUES ('20130820180352');

INSERT INTO schema_migrations (version) VALUES ('20130821191332');

INSERT INTO schema_migrations (version) VALUES ('20130822022544');

INSERT INTO schema_migrations (version) VALUES ('20130826181153');

INSERT INTO schema_migrations (version) VALUES ('20130827173405');

INSERT INTO schema_migrations (version) VALUES ('20130827183432');

INSERT INTO schema_migrations (version) VALUES ('20130904042040');

INSERT INTO schema_migrations (version) VALUES ('20130921224415');

INSERT INTO schema_migrations (version) VALUES ('20130921225406');

INSERT INTO schema_migrations (version) VALUES ('20130925213523');

INSERT INTO schema_migrations (version) VALUES ('20130930184513');

INSERT INTO schema_migrations (version) VALUES ('20130930205900');

INSERT INTO schema_migrations (version) VALUES ('20131002172022');

INSERT INTO schema_migrations (version) VALUES ('20131004175052');

INSERT INTO schema_migrations (version) VALUES ('20131006161731');

INSERT INTO schema_migrations (version) VALUES ('20131006190252');

INSERT INTO schema_migrations (version) VALUES ('20131106025929');

INSERT INTO schema_migrations (version) VALUES ('20131106034344');

INSERT INTO schema_migrations (version) VALUES ('20131106035830');

INSERT INTO schema_migrations (version) VALUES ('20131106042229');

INSERT INTO schema_migrations (version) VALUES ('20131106043131');

INSERT INTO schema_migrations (version) VALUES ('20131108205446');

INSERT INTO schema_migrations (version) VALUES ('20131108224636');

INSERT INTO schema_migrations (version) VALUES ('20131112232223');

INSERT INTO schema_migrations (version) VALUES ('20131113024418');

INSERT INTO schema_migrations (version) VALUES ('20131113201402');

INSERT INTO schema_migrations (version) VALUES ('20131113202229');

INSERT INTO schema_migrations (version) VALUES ('20131119071615');

INSERT INTO schema_migrations (version) VALUES ('20131125211740');

INSERT INTO schema_migrations (version) VALUES ('20131125212800');

INSERT INTO schema_migrations (version) VALUES ('20131125221624');

INSERT INTO schema_migrations (version) VALUES ('20131125231729');

INSERT INTO schema_migrations (version) VALUES ('20131205015135');

INSERT INTO schema_migrations (version) VALUES ('20131205030406');

INSERT INTO schema_migrations (version) VALUES ('20131206002446');

INSERT INTO schema_migrations (version) VALUES ('20131206023239');

INSERT INTO schema_migrations (version) VALUES ('20131206023607');

INSERT INTO schema_migrations (version) VALUES ('20131209233307');

INSERT INTO schema_migrations (version) VALUES ('20131211042607');

INSERT INTO schema_migrations (version) VALUES ('20131212054732');

INSERT INTO schema_migrations (version) VALUES ('20131212235428');

INSERT INTO schema_migrations (version) VALUES ('20131213021924');

INSERT INTO schema_migrations (version) VALUES ('20131213041133');

INSERT INTO schema_migrations (version) VALUES ('20131213042742');

INSERT INTO schema_migrations (version) VALUES ('20131216222208');

INSERT INTO schema_migrations (version) VALUES ('20131216231047');

INSERT INTO schema_migrations (version) VALUES ('20131216231121');

INSERT INTO schema_migrations (version) VALUES ('20131218232301');

INSERT INTO schema_migrations (version) VALUES ('20131218234340');

INSERT INTO schema_migrations (version) VALUES ('20131220220200');

INSERT INTO schema_migrations (version) VALUES ('20131220220351');

INSERT INTO schema_migrations (version) VALUES ('20131220221530');

INSERT INTO schema_migrations (version) VALUES ('20131221010609');

INSERT INTO schema_migrations (version) VALUES ('20131221055220');

INSERT INTO schema_migrations (version) VALUES ('20131221055529');

INSERT INTO schema_migrations (version) VALUES ('20131222013816');

INSERT INTO schema_migrations (version) VALUES ('20131222014659');

INSERT INTO schema_migrations (version) VALUES ('20131224212832');

INSERT INTO schema_migrations (version) VALUES ('20140102004634');

INSERT INTO schema_migrations (version) VALUES ('20140108212131');

INSERT INTO schema_migrations (version) VALUES ('20140108212543');

INSERT INTO schema_migrations (version) VALUES ('20140126025953');

INSERT INTO schema_migrations (version) VALUES ('20140127185544');

INSERT INTO schema_migrations (version) VALUES ('20140127211352');

INSERT INTO schema_migrations (version) VALUES ('20140129223622');

INSERT INTO schema_migrations (version) VALUES ('20140129230126');

INSERT INTO schema_migrations (version) VALUES ('20140129230318');

INSERT INTO schema_migrations (version) VALUES ('20140216033123');

INSERT INTO schema_migrations (version) VALUES ('20140216035737');

INSERT INTO schema_migrations (version) VALUES ('20140216035828');

INSERT INTO schema_migrations (version) VALUES ('20140217225832');

INSERT INTO schema_migrations (version) VALUES ('20140217230156');

INSERT INTO schema_migrations (version) VALUES ('20140219070330');

INSERT INTO schema_migrations (version) VALUES ('20140221025628');

INSERT INTO schema_migrations (version) VALUES ('20140222031116');

INSERT INTO schema_migrations (version) VALUES ('20140223010212');

INSERT INTO schema_migrations (version) VALUES ('20140223073741');

INSERT INTO schema_migrations (version) VALUES ('20140317231021');

INSERT INTO schema_migrations (version) VALUES ('20140317231318');

INSERT INTO schema_migrations (version) VALUES ('20140328000212');

INSERT INTO schema_migrations (version) VALUES ('20140328012232');

INSERT INTO schema_migrations (version) VALUES ('20140407221310');

INSERT INTO schema_migrations (version) VALUES ('20140430210409');

INSERT INTO schema_migrations (version) VALUES ('20140430211518');

INSERT INTO schema_migrations (version) VALUES ('20140430213501');

INSERT INTO schema_migrations (version) VALUES ('20140430233349');

INSERT INTO schema_migrations (version) VALUES ('20140501175340');

INSERT INTO schema_migrations (version) VALUES ('20140503233456');

INSERT INTO schema_migrations (version) VALUES ('20140511033511');

INSERT INTO schema_migrations (version) VALUES ('20140511184653');

INSERT INTO schema_migrations (version) VALUES ('20140520205226');

INSERT INTO schema_migrations (version) VALUES ('20140528160918');

INSERT INTO schema_migrations (version) VALUES ('20140606163447');

INSERT INTO schema_migrations (version) VALUES ('20140606232123');

INSERT INTO schema_migrations (version) VALUES ('20140610175059');

INSERT INTO schema_migrations (version) VALUES ('20140611155122');

INSERT INTO schema_migrations (version) VALUES ('20140614233125');

INSERT INTO schema_migrations (version) VALUES ('20140616190340');

INSERT INTO schema_migrations (version) VALUES ('20140616192924');

INSERT INTO schema_migrations (version) VALUES ('20140630181821');

INSERT INTO schema_migrations (version) VALUES ('20140702013410');

INSERT INTO schema_migrations (version) VALUES ('20140702180325');

INSERT INTO schema_migrations (version) VALUES ('20140707155940');

INSERT INTO schema_migrations (version) VALUES ('20140708181534');

INSERT INTO schema_migrations (version) VALUES ('20140709190718');

INSERT INTO schema_migrations (version) VALUES ('20140709192318');

INSERT INTO schema_migrations (version) VALUES ('20140709204055');

INSERT INTO schema_migrations (version) VALUES ('20140709210712');

INSERT INTO schema_migrations (version) VALUES ('20140709213909');

INSERT INTO schema_migrations (version) VALUES ('20140709223253');

INSERT INTO schema_migrations (version) VALUES ('20140709230823');

INSERT INTO schema_migrations (version) VALUES ('20140710214131');

INSERT INTO schema_migrations (version) VALUES ('20140718220840');

INSERT INTO schema_migrations (version) VALUES ('20140720214847');

INSERT INTO schema_migrations (version) VALUES ('20140721195953');

INSERT INTO schema_migrations (version) VALUES ('20140721211944');

INSERT INTO schema_migrations (version) VALUES ('20140722221532');

INSERT INTO schema_migrations (version) VALUES ('20140723185451');

INSERT INTO schema_migrations (version) VALUES ('20140723222514');

INSERT INTO schema_migrations (version) VALUES ('20140724002918');

INSERT INTO schema_migrations (version) VALUES ('20140805230423');

INSERT INTO schema_migrations (version) VALUES ('20140806001210');

INSERT INTO schema_migrations (version) VALUES ('20140806172832');

INSERT INTO schema_migrations (version) VALUES ('20140806174011');

INSERT INTO schema_migrations (version) VALUES ('20140808234001');

INSERT INTO schema_migrations (version) VALUES ('20140811181505');

INSERT INTO schema_migrations (version) VALUES ('20140821192441');

INSERT INTO schema_migrations (version) VALUES ('20140821212140');

INSERT INTO schema_migrations (version) VALUES ('20140822195714');

INSERT INTO schema_migrations (version) VALUES ('20140827171815');

INSERT INTO schema_migrations (version) VALUES ('20140908191013');

INSERT INTO schema_migrations (version) VALUES ('20140908225939');

INSERT INTO schema_migrations (version) VALUES ('20140908232010');

INSERT INTO schema_migrations (version) VALUES ('20140909220940');

INSERT INTO schema_migrations (version) VALUES ('20140910010244');

INSERT INTO schema_migrations (version) VALUES ('20140911201342');

INSERT INTO schema_migrations (version) VALUES ('20140925180124');

INSERT INTO schema_migrations (version) VALUES ('20141015182304');

INSERT INTO schema_migrations (version) VALUES ('20141016002717');

INSERT INTO schema_migrations (version) VALUES ('20141016174735');

INSERT INTO schema_migrations (version) VALUES ('20141017223033');

INSERT INTO schema_migrations (version) VALUES ('20141022003044');

INSERT INTO schema_migrations (version) VALUES ('20141028171214');

INSERT INTO schema_migrations (version) VALUES ('20141030214435');

INSERT INTO schema_migrations (version) VALUES ('20141030214648');

INSERT INTO schema_migrations (version) VALUES ('20141103040303');

INSERT INTO schema_migrations (version) VALUES ('20141106182116');

INSERT INTO schema_migrations (version) VALUES ('20141106223101');

INSERT INTO schema_migrations (version) VALUES ('20141110233145');

INSERT INTO schema_migrations (version) VALUES ('20141121191153');

INSERT INTO schema_migrations (version) VALUES ('20141122012437');

INSERT INTO schema_migrations (version) VALUES ('20141212154700');

INSERT INTO schema_migrations (version) VALUES ('20141212191850');

INSERT INTO schema_migrations (version) VALUES ('20141219232322');

INSERT INTO schema_migrations (version) VALUES ('20150109200006');

INSERT INTO schema_migrations (version) VALUES ('20150121022029');

INSERT INTO schema_migrations (version) VALUES ('20150121181359');

INSERT INTO schema_migrations (version) VALUES ('20150121181360');

INSERT INTO schema_migrations (version) VALUES ('20150121234212');

INSERT INTO schema_migrations (version) VALUES ('20150129004605');

INSERT INTO schema_migrations (version) VALUES ('20150130001528');

INSERT INTO schema_migrations (version) VALUES ('20150204011831');

INSERT INTO schema_migrations (version) VALUES ('20150211223056');

INSERT INTO schema_migrations (version) VALUES ('20150212003325');

INSERT INTO schema_migrations (version) VALUES ('20150212190054');

INSERT INTO schema_migrations (version) VALUES ('20150218012144');

INSERT INTO schema_migrations (version) VALUES ('20150227190235');

INSERT INTO schema_migrations (version) VALUES ('20150307014612');

INSERT INTO schema_migrations (version) VALUES ('20150312182725');

INSERT INTO schema_migrations (version) VALUES ('20150317004955');

INSERT INTO schema_migrations (version) VALUES ('20150317171721');

INSERT INTO schema_migrations (version) VALUES ('20150326185645');

INSERT INTO schema_migrations (version) VALUES ('20150326190344');

INSERT INTO schema_migrations (version) VALUES ('20150327174356');

INSERT INTO schema_migrations (version) VALUES ('20150330204144');

INSERT INTO schema_migrations (version) VALUES ('20150402063609');

INSERT INTO schema_migrations (version) VALUES ('20150402205908');

INSERT INTO schema_migrations (version) VALUES ('20150406140810');

INSERT INTO schema_migrations (version) VALUES ('20150414000103');

INSERT INTO schema_migrations (version) VALUES ('20150424182907');

INSERT INTO schema_migrations (version) VALUES ('20150424212050');

INSERT INTO schema_migrations (version) VALUES ('20150506174510');

INSERT INTO schema_migrations (version) VALUES ('20150507213234');

INSERT INTO schema_migrations (version) VALUES ('20150519222039');

INSERT INTO schema_migrations (version) VALUES ('20150528011117');

INSERT INTO schema_migrations (version) VALUES ('20150528213325');

INSERT INTO schema_migrations (version) VALUES ('20150605001244');

INSERT INTO schema_migrations (version) VALUES ('20150605194759');

INSERT INTO schema_migrations (version) VALUES ('20150606165608');

INSERT INTO schema_migrations (version) VALUES ('20150608202135');

INSERT INTO schema_migrations (version) VALUES ('20150612063834');

INSERT INTO schema_migrations (version) VALUES ('20150616204323');

INSERT INTO schema_migrations (version) VALUES ('20150622214437');

INSERT INTO schema_migrations (version) VALUES ('20150624233212');

INSERT INTO schema_migrations (version) VALUES ('20150625224248');

INSERT INTO schema_migrations (version) VALUES ('20150626192051');

INSERT INTO schema_migrations (version) VALUES ('20150629205422');

INSERT INTO schema_migrations (version) VALUES ('20150708001411');

INSERT INTO schema_migrations (version) VALUES ('20150709000507');

INSERT INTO schema_migrations (version) VALUES ('20150713193839');

INSERT INTO schema_migrations (version) VALUES ('20150716154253');

INSERT INTO schema_migrations (version) VALUES ('20150720200146');

INSERT INTO schema_migrations (version) VALUES ('20150727000000');

INSERT INTO schema_migrations (version) VALUES ('20150727221732');

INSERT INTO schema_migrations (version) VALUES ('20150727232443');

INSERT INTO schema_migrations (version) VALUES ('20150730170540');

INSERT INTO schema_migrations (version) VALUES ('20150801001957');

INSERT INTO schema_migrations (version) VALUES ('20150803214819');

INSERT INTO schema_migrations (version) VALUES ('20150804214255');

INSERT INTO schema_migrations (version) VALUES ('20150805221334');

INSERT INTO schema_migrations (version) VALUES ('20150806184226');

INSERT INTO schema_migrations (version) VALUES ('20150901191550');

INSERT INTO schema_migrations (version) VALUES ('20150914223407');

INSERT INTO schema_migrations (version) VALUES ('20150918231034');

INSERT INTO schema_migrations (version) VALUES ('20150930000613');

INSERT INTO schema_migrations (version) VALUES ('20151001000455');

INSERT INTO schema_migrations (version) VALUES ('20151001010557');

INSERT INTO schema_migrations (version) VALUES ('20151003202625');

INSERT INTO schema_migrations (version) VALUES ('20151003202658');

INSERT INTO schema_migrations (version) VALUES ('20151003202719');

INSERT INTO schema_migrations (version) VALUES ('20151003205146');

INSERT INTO schema_migrations (version) VALUES ('20151009224532');

INSERT INTO schema_migrations (version) VALUES ('20151010211429');

INSERT INTO schema_migrations (version) VALUES ('20151010215033');

INSERT INTO schema_migrations (version) VALUES ('20151011210555');

INSERT INTO schema_migrations (version) VALUES ('20151015235805');

INSERT INTO schema_migrations (version) VALUES ('20151016195358');

INSERT INTO schema_migrations (version) VALUES ('20151016230758');

INSERT INTO schema_migrations (version) VALUES ('20151019211403');

INSERT INTO schema_migrations (version) VALUES ('20151019211658');

INSERT INTO schema_migrations (version) VALUES ('20151019212230');

INSERT INTO schema_migrations (version) VALUES ('20151019213217');

INSERT INTO schema_migrations (version) VALUES ('20151019215743');

INSERT INTO schema_migrations (version) VALUES ('20151021162446');

INSERT INTO schema_migrations (version) VALUES ('20151022175345');

INSERT INTO schema_migrations (version) VALUES ('20151026230655');

INSERT INTO schema_migrations (version) VALUES ('20151026230941');

INSERT INTO schema_migrations (version) VALUES ('20151027182344');

INSERT INTO schema_migrations (version) VALUES ('20151028234328');

INSERT INTO schema_migrations (version) VALUES ('20151102212726');

INSERT INTO schema_migrations (version) VALUES ('20151103172430');

INSERT INTO schema_migrations (version) VALUES ('20151103181526');

INSERT INTO schema_migrations (version) VALUES ('20151104180332');

INSERT INTO schema_migrations (version) VALUES ('20151106192352');

INSERT INTO schema_migrations (version) VALUES ('20151116000000');

INSERT INTO schema_migrations (version) VALUES ('20151117000001');

INSERT INTO schema_migrations (version) VALUES ('20151117191440');

INSERT INTO schema_migrations (version) VALUES ('20151118015601');

INSERT INTO schema_migrations (version) VALUES ('20151210000000');

INSERT INTO schema_migrations (version) VALUES ('20151211000000');

INSERT INTO schema_migrations (version) VALUES ('20151510000000');

INSERT INTO schema_migrations (version) VALUES ('20151511000000');

INSERT INTO schema_migrations (version) VALUES ('20160112231714');

INSERT INTO schema_migrations (version) VALUES ('20160113195445');

INSERT INTO schema_migrations (version) VALUES ('20160120191500');

INSERT INTO schema_migrations (version) VALUES ('20160120191749');

INSERT INTO schema_migrations (version) VALUES ('20160208225037');

INSERT INTO schema_migrations (version) VALUES ('20160217025856');

INSERT INTO schema_migrations (version) VALUES ('20160310013605');

INSERT INTO schema_migrations (version) VALUES ('20160310190727');

INSERT INTO schema_migrations (version) VALUES ('20160315233429');

INSERT INTO schema_migrations (version) VALUES ('20160317004443');

INSERT INTO schema_migrations (version) VALUES ('20160323195059');

INSERT INTO schema_migrations (version) VALUES ('20160407003745');

INSERT INTO schema_migrations (version) VALUES ('20160418233007');

INSERT INTO schema_migrations (version) VALUES ('20160426001622');

INSERT INTO schema_migrations (version) VALUES ('20160502191235');

INSERT INTO schema_migrations (version) VALUES ('20160503211508');

INSERT INTO schema_migrations (version) VALUES ('20160505230247');

INSERT INTO schema_migrations (version) VALUES ('20160509194616');

INSERT INTO schema_migrations (version) VALUES ('20160511154224');

INSERT INTO schema_migrations (version) VALUES ('20160511232059');

INSERT INTO schema_migrations (version) VALUES ('20160525045440');

INSERT INTO schema_migrations (version) VALUES ('20160530004848');

INSERT INTO schema_migrations (version) VALUES ('20160603001055');

INSERT INTO schema_migrations (version) VALUES ('20160606180420');

INSERT INTO schema_migrations (version) VALUES ('20160622210950');

INSERT INTO schema_migrations (version) VALUES ('20160629161438');

INSERT INTO schema_migrations (version) VALUES ('20160705192643');

INSERT INTO schema_migrations (version) VALUES ('20160707173036');

INSERT INTO schema_migrations (version) VALUES ('20160707173447');

INSERT INTO schema_migrations (version) VALUES ('20160712161901');

INSERT INTO schema_migrations (version) VALUES ('20160714232656');

INSERT INTO schema_migrations (version) VALUES ('20160714233405');

INSERT INTO schema_migrations (version) VALUES ('20160729175556');

INSERT INTO schema_migrations (version) VALUES ('20160803182417');

INSERT INTO schema_migrations (version) VALUES ('20160803185600');

INSERT INTO schema_migrations (version) VALUES ('20160804223230');

INSERT INTO schema_migrations (version) VALUES ('20160808144134');

INSERT INTO schema_migrations (version) VALUES ('20160808145939');

INSERT INTO schema_migrations (version) VALUES ('20160809000508');

INSERT INTO schema_migrations (version) VALUES ('20160809232303');

INSERT INTO schema_migrations (version) VALUES ('20160816183448');

INSERT INTO schema_migrations (version) VALUES ('20160909000556');

INSERT INTO schema_migrations (version) VALUES ('20160909001649');

INSERT INTO schema_migrations (version) VALUES ('20161017162710');

INSERT INTO schema_migrations (version) VALUES ('20161020231839');

INSERT INTO schema_migrations (version) VALUES ('20161025180615');

INSERT INTO schema_migrations (version) VALUES ('20161031225409');

INSERT INTO schema_migrations (version) VALUES ('20161219202411');

INSERT INTO schema_migrations (version) VALUES ('20161228205838');

INSERT INTO schema_migrations (version) VALUES ('20161230194731');

INSERT INTO schema_migrations (version) VALUES ('20170106001404');

INSERT INTO schema_migrations (version) VALUES ('20170214185152');

INSERT INTO schema_migrations (version) VALUES ('20170214230601');

INSERT INTO schema_migrations (version) VALUES ('20170214231056');

INSERT INTO schema_migrations (version) VALUES ('20170215233354');

INSERT INTO schema_migrations (version) VALUES ('20170307222633');

INSERT INTO schema_migrations (version) VALUES ('20170307223525');

INSERT INTO schema_migrations (version) VALUES ('20170314193744');

INSERT INTO schema_migrations (version) VALUES ('20170322203228');

INSERT INTO schema_migrations (version) VALUES ('20170805180556');

INSERT INTO schema_migrations (version) VALUES ('20170805180557');

INSERT INTO schema_migrations (version) VALUES ('20170805180558');

INSERT INTO schema_migrations (version) VALUES ('20170805180559');

INSERT INTO schema_migrations (version) VALUES ('20170808180559');

INSERT INTO schema_migrations (version) VALUES ('20170818201127');

INSERT INTO schema_migrations (version) VALUES ('20171002160808');

INSERT INTO schema_migrations (version) VALUES ('20171002164402');

INSERT INTO schema_migrations (version) VALUES ('20171004203633');

INSERT INTO schema_migrations (version) VALUES ('20171010204437');

INSERT INTO schema_migrations (version) VALUES ('20171016181942');

INSERT INTO schema_migrations (version) VALUES ('20171024133806');

INSERT INTO schema_migrations (version) VALUES ('20171026102139');

INSERT INTO schema_migrations (version) VALUES ('20171129215957');

INSERT INTO schema_migrations (version) VALUES ('20171130182254');

INSERT INTO schema_migrations (version) VALUES ('20171130193955');

INSERT INTO schema_migrations (version) VALUES ('20171206113317');

INSERT INTO schema_migrations (version) VALUES ('20171207114229');

INSERT INTO schema_migrations (version) VALUES ('20171207191435');

INSERT INTO schema_migrations (version) VALUES ('20171207191712');

INSERT INTO schema_migrations (version) VALUES ('20171207200746');

INSERT INTO schema_migrations (version) VALUES ('20171207200950');

INSERT INTO schema_migrations (version) VALUES ('20171207210431');

INSERT INTO schema_migrations (version) VALUES ('20180106024119');

INSERT INTO schema_migrations (version) VALUES ('20180119215653');

INSERT INTO schema_migrations (version) VALUES ('20180119215913');

INSERT INTO schema_migrations (version) VALUES ('20180202181929');

INSERT INTO schema_migrations (version) VALUES ('20180213191755');

INSERT INTO schema_migrations (version) VALUES ('20180214124311');

INSERT INTO schema_migrations (version) VALUES ('20180215124311');

INSERT INTO schema_migrations (version) VALUES ('20180216064311');

INSERT INTO schema_migrations (version) VALUES ('20180216124311');

INSERT INTO schema_migrations (version) VALUES ('20180217124311');

INSERT INTO schema_migrations (version) VALUES ('20180608205049');

INSERT INTO schema_migrations (version) VALUES ('20180608212658');

INSERT INTO schema_migrations (version) VALUES ('20180703165401');

INSERT INTO schema_migrations (version) VALUES ('20180703165402');

INSERT INTO schema_migrations (version) VALUES ('20180703165404');

INSERT INTO schema_migrations (version) VALUES ('20180703165405');

INSERT INTO schema_migrations (version) VALUES ('20180713213748');

INSERT INTO schema_migrations (version) VALUES ('20180713215825');

INSERT INTO schema_migrations (version) VALUES ('20180713220028');

INSERT INTO schema_migrations (version) VALUES ('20181002160627');

INSERT INTO schema_migrations (version) VALUES ('20181003212559');

INSERT INTO schema_migrations (version) VALUES ('20181026175740');

INSERT INTO schema_migrations (version) VALUES ('20181120182105');

INSERT INTO schema_migrations (version) VALUES ('20181128221143');

INSERT INTO schema_migrations (version) VALUES ('20181129205652');

INSERT INTO schema_migrations (version) VALUES ('20181129224030');

INSERT INTO schema_migrations (version) VALUES ('20190522162746');

INSERT INTO schema_migrations (version) VALUES ('20190820205820');

INSERT INTO schema_migrations (version) VALUES ('20190820205841');

INSERT INTO schema_migrations (version) VALUES ('20191001174129');

INSERT INTO schema_migrations (version) VALUES ('20191122173716');

INSERT INTO schema_migrations (version) VALUES ('20191204021126');

INSERT INTO schema_migrations (version) VALUES ('20200107212543');

INSERT INTO schema_migrations (version) VALUES ('20200108213844');

INSERT INTO schema_migrations (version) VALUES ('20200130222233');

INSERT INTO schema_migrations (version) VALUES ('20200213200444');

INSERT INTO schema_migrations (version) VALUES ('20200304225530');

INSERT INTO schema_migrations (version) VALUES ('20200316165956');

INSERT INTO schema_migrations (version) VALUES ('20200319203257');

INSERT INTO schema_migrations (version) VALUES ('20200408192744');

INSERT INTO schema_migrations (version) VALUES ('20200408194203');

INSERT INTO schema_migrations (version) VALUES ('20200408194348');

INSERT INTO schema_migrations (version) VALUES ('20200409160802');

INSERT INTO schema_migrations (version) VALUES ('20200409165524');

INSERT INTO schema_migrations (version) VALUES ('20200409171035');

INSERT INTO schema_migrations (version) VALUES ('20200409191419');

INSERT INTO schema_migrations (version) VALUES ('20200415170547');

INSERT INTO schema_migrations (version) VALUES ('20200415202723');

INSERT INTO schema_migrations (version) VALUES ('20200415212209');

INSERT INTO schema_migrations (version) VALUES ('20200415214804');

INSERT INTO schema_migrations (version) VALUES ('20200415220410');

INSERT INTO schema_migrations (version) VALUES ('20200415220722');

INSERT INTO schema_migrations (version) VALUES ('20200415222354');

INSERT INTO schema_migrations (version) VALUES ('20200415223903');

INSERT INTO schema_migrations (version) VALUES ('20200415230146');

INSERT INTO schema_migrations (version) VALUES ('20200416163347');

INSERT INTO schema_migrations (version) VALUES ('20200416163530');

INSERT INTO schema_migrations (version) VALUES ('20200416173740');

INSERT INTO schema_migrations (version) VALUES ('20200421185917');

INSERT INTO schema_migrations (version) VALUES ('20200731205823');

INSERT INTO schema_migrations (version) VALUES ('20200805214509');

INSERT INTO schema_migrations (version) VALUES ('20200805214542');

INSERT INTO schema_migrations (version) VALUES ('20200805214543');

INSERT INTO schema_migrations (version) VALUES ('20200819200849');

INSERT INTO schema_migrations (version) VALUES ('20200821192204');

INSERT INTO schema_migrations (version) VALUES ('20200821230919');

INSERT INTO schema_migrations (version) VALUES ('20200901185347');

INSERT INTO schema_migrations (version) VALUES ('20200903180732');

INSERT INTO schema_migrations (version) VALUES ('20200914193909');

INSERT INTO schema_migrations (version) VALUES ('20200918182519');

INSERT INTO schema_migrations (version) VALUES ('20200928205836');

INSERT INTO schema_migrations (version) VALUES ('20201001161244');

INSERT INTO schema_migrations (version) VALUES ('20201001161316');

INSERT INTO schema_migrations (version) VALUES ('20201001161338');

INSERT INTO schema_migrations (version) VALUES ('20201001162737');

INSERT INTO schema_migrations (version) VALUES ('20201103170055');

INSERT INTO schema_migrations (version) VALUES ('20201214214347');

INSERT INTO schema_migrations (version) VALUES ('20210413201029');

INSERT INTO schema_migrations (version) VALUES ('20210416141243');

INSERT INTO schema_migrations (version) VALUES ('20210416143448');

INSERT INTO schema_migrations (version) VALUES ('20210521210949');

INSERT INTO schema_migrations (version) VALUES ('20210524185334');

INSERT INTO schema_migrations (version) VALUES ('20210524185342');

INSERT INTO schema_migrations (version) VALUES ('20210607214751');

INSERT INTO schema_migrations (version) VALUES ('20210712192642');

INSERT INTO schema_migrations (version) VALUES ('20210714215241');

INSERT INTO schema_migrations (version) VALUES ('20210715191012');

INSERT INTO schema_migrations (version) VALUES ('20210721175103');

INSERT INTO schema_migrations (version) VALUES ('20210804203440');

INSERT INTO schema_migrations (version) VALUES ('20210812220753');

INSERT INTO schema_migrations (version) VALUES ('20210818221411');

INSERT INTO schema_migrations (version) VALUES ('20210917204956');

INSERT INTO schema_migrations (version) VALUES ('20210929200206');

INSERT INTO schema_migrations (version) VALUES ('20210930192755');

INSERT INTO schema_migrations (version) VALUES ('20210930194624');

INSERT INTO schema_migrations (version) VALUES ('20211001194346');

INSERT INTO schema_migrations (version) VALUES ('20211001194416');

INSERT INTO schema_migrations (version) VALUES ('20211004124725');

INSERT INTO schema_migrations (version) VALUES ('20211004130610');

INSERT INTO schema_migrations (version) VALUES ('20211004173137');

INSERT INTO schema_migrations (version) VALUES ('20211004173808');

INSERT INTO schema_migrations (version) VALUES ('20211019205925');

INSERT INTO schema_migrations (version) VALUES ('20211021173546');

INSERT INTO schema_migrations (version) VALUES ('20211025145718');

INSERT INTO schema_migrations (version) VALUES ('20211101221537');

INSERT INTO schema_migrations (version) VALUES ('20211104195053');

INSERT INTO schema_migrations (version) VALUES ('20211119224854');

INSERT INTO schema_migrations (version) VALUES ('20211210185111');

INSERT INTO schema_migrations (version) VALUES ('20211222175658');

INSERT INTO schema_migrations (version) VALUES ('20220119193044');

INSERT INTO schema_migrations (version) VALUES ('20220209203456');

INSERT INTO schema_migrations (version) VALUES ('20220210231629');
