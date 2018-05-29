--
-- PostgreSQL database dump
--

<<<<<<< HEAD
<<<<<<< HEAD
-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 9.6.10
=======
-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8
>>>>>>> Add CampaignTemplate
=======
-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1
>>>>>>> wip

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


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


SET search_path = public, pg_catalog;

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
-- Name: update_supporter_assoc_search_vectors(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_supporter_assoc_search_vectors() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
      IF pg_trigger_depth() <> 1 THEN RETURN new; END IF;
      UPDATE supporters
        SET search_vectors=to_tsvector('english', data.search_blob)
        FROM (
SELECT supporters.id, concat_ws(' '
        , custom_field_joins.value
        , supporters.name
        , supporters.organization
        , supporters.id
        , supporters.email
        , supporters.city
        , supporters.state_code
        , donations.designation
        , donations.dedication
        , payments.kind
        , payments.towards
        ) AS search_blob
FROM supporters
LEFT OUTER JOIN payments
  ON payments.supporter_id=supporters.id
LEFT OUTER JOIN donations
  ON donations.supporter_id=supporters.id
LEFT OUTER JOIN (
SELECT string_agg(value::text, ' ') AS value, supporter_id
FROM custom_field_joins
GROUP BY supporter_id) AS custom_field_joins
  ON custom_field_joins.supporter_id=supporters.id
WHERE (supporters.id=NEW.supporter_id)) AS data
        WHERE data.id=supporters.id;
      RETURN new;
    END $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE activities (
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
    json_data text
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bank_accounts (
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
    deleted boolean
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bank_accounts_id_seq OWNED BY bank_accounts.id;


--
-- Name: billing_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE billing_plans (
    id integer NOT NULL,
    name character varying(255),
    stripe_plan_id character varying(255),
    amount integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tier integer,
    "interval" character varying(255),
    percentage_fee real DEFAULT 0 NOT NULL
);


--
-- Name: billing_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE billing_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE billing_plans_id_seq OWNED BY billing_plans.id;


--
-- Name: billing_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE billing_subscriptions (
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

CREATE SEQUENCE billing_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE billing_subscriptions_id_seq OWNED BY billing_subscriptions.id;


--
-- Name: campaign_gift_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE campaign_gift_options (
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

CREATE SEQUENCE campaign_gift_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_gift_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaign_gift_options_id_seq OWNED BY campaign_gift_options.id;


--
-- Name: campaign_gifts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE campaign_gifts (
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

CREATE SEQUENCE campaign_gifts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_gifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaign_gifts_id_seq OWNED BY campaign_gifts.id;


--
-- Name: campaign_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE campaign_templates (
    id integer NOT NULL,
    template_name character varying(255) NOT NULL,
    name character varying(255),
    tagline character varying(255),
    goal_amount integer,
    main_image character varying(255),
    video_url text,
    vimeo_video_id character varying(255),
    youtube_video_id character varying(255),
    summary text,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nonprofit_id integer
);


--
-- Name: campaign_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaign_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaign_templates_id_seq OWNED BY campaign_templates.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE campaigns (
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
    deleted boolean,
    hide_title boolean,
    hide_thermometer boolean,
    hide_goal boolean,
    receipt_message text,
    hide_custom_amounts boolean,
    show_recurring_amount boolean DEFAULT false,
    end_datetime timestamp without time zone,
    external_identifier character varying(255),
    campaign_template_id integer,
    parent_campaign_id integer,
    reason_for_supporting text,
    default_reason_for_supporting text
);


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaigns_id_seq OWNED BY campaigns.id;


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cards (
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
    deleted boolean,
    inactive boolean
);


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cards_id_seq OWNED BY cards.id;


--
-- Name: charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE charges (
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

CREATE SEQUENCE charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE charges_id_seq OWNED BY charges.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comments (
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

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: custom_field_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE custom_field_joins (
    id integer NOT NULL,
    custom_field_master_id integer,
    supporter_id integer,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_field_joins_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE custom_field_joins_backup (
    id integer NOT NULL,
    custom_field_master_id integer,
    supporter_id integer,
    metadata text,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_field_joins_backup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE custom_field_joins_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_field_joins_backup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE custom_field_joins_backup_id_seq OWNED BY custom_field_joins_backup.id;


--
-- Name: custom_field_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE custom_field_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_field_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE custom_field_joins_id_seq OWNED BY custom_field_joins.id;


--
-- Name: custom_field_masters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE custom_field_masters (
    id integer NOT NULL,
    name character varying(255),
    nonprofit_id integer,
    deleted boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_field_masters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE custom_field_masters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_field_masters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE custom_field_masters_id_seq OWNED BY custom_field_masters.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
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

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: direct_debit_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE direct_debit_details (
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

CREATE SEQUENCE direct_debit_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: direct_debit_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE direct_debit_details_id_seq OWNED BY direct_debit_details.id;


--
-- Name: disputes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE disputes (
    id integer NOT NULL,
    gross_amount integer,
    charge_id integer,
    payment_id integer,
    reason character varying(255),
    status character varying(255),
    stripe_dispute_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: disputes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE disputes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disputes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE disputes_id_seq OWNED BY disputes.id;


--
-- Name: donations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE donations (
    id integer NOT NULL,
    amount integer,
    profile_id integer,
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    card_id integer,
    designation text,
    offsite boolean,
    anonymous boolean,
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
    payment_provider character varying(255)
);


--
-- Name: donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE donations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE donations_id_seq OWNED BY donations.id;


--
-- Name: donations_payment_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE donations_payment_imports (
    donation_id integer,
    payment_import_id integer
);


--
-- Name: email_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE email_lists (
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

CREATE SEQUENCE email_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_lists_id_seq OWNED BY email_lists.id;


--
-- Name: email_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE email_settings (
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

CREATE SEQUENCE email_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_settings_id_seq OWNED BY email_settings.id;


--
-- Name: event_discounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE event_discounts (
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

CREATE SEQUENCE event_discounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_discounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_discounts_id_seq OWNED BY event_discounts.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
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
    deleted boolean,
    receipt_message text,
    organizer_email character varying(255),
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE exports (
    id integer NOT NULL,
    user_id integer,
    nonprofit_id integer,
    status character varying(255),
    exception character varying(255),
    ended timestamp without time zone,
    export_type character varying(255),
    parameters character varying(255),
    url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exports_id_seq OWNED BY exports.id;


--
-- Name: full_contact_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE full_contact_infos (
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

CREATE SEQUENCE full_contact_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_contact_infos_id_seq OWNED BY full_contact_infos.id;


--
-- Name: full_contact_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE full_contact_jobs (
    id integer NOT NULL,
    supporter_id integer
);


--
-- Name: full_contact_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE full_contact_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_contact_jobs_id_seq OWNED BY full_contact_jobs.id;


--
-- Name: full_contact_orgs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE full_contact_orgs (
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

CREATE SEQUENCE full_contact_orgs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_orgs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_contact_orgs_id_seq OWNED BY full_contact_orgs.id;


--
-- Name: full_contact_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE full_contact_photos (
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

CREATE SEQUENCE full_contact_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_contact_photos_id_seq OWNED BY full_contact_photos.id;


--
-- Name: full_contact_social_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE full_contact_social_profiles (
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

CREATE SEQUENCE full_contact_social_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_social_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_contact_social_profiles_id_seq OWNED BY full_contact_social_profiles.id;


--
-- Name: full_contact_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE full_contact_topics (
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

CREATE SEQUENCE full_contact_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_contact_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_contact_topics_id_seq OWNED BY full_contact_topics.id;


--
-- Name: image_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_attachments (
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

CREATE SEQUENCE image_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE image_attachments_id_seq OWNED BY image_attachments.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE imports (
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

CREATE SEQUENCE imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE imports_id_seq OWNED BY imports.id;


--
-- Name: miscellaneous_np_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE miscellaneous_np_infos (
    id integer NOT NULL,
    donate_again_url character varying(255),
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    change_amount_message text
);


--
-- Name: miscellaneous_np_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE miscellaneous_np_infos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: miscellaneous_np_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE miscellaneous_np_infos_id_seq OWNED BY miscellaneous_np_infos.id;


--
-- Name: nonprofit_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE nonprofit_keys (
    id integer NOT NULL,
    nonprofit_id integer,
    mailchimp_token text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nonprofit_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nonprofit_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nonprofit_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nonprofit_keys_id_seq OWNED BY nonprofit_keys.id;


--
-- Name: nonprofits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE nonprofits (
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
    pending_balance integer,
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
    verification_status character varying(255),
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
    currency character varying(255) DEFAULT 'eur'::character varying,
    custom_layout character varying(255)
);


--
-- Name: nonprofits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nonprofits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nonprofits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nonprofits_id_seq OWNED BY nonprofits.id;


--
-- Name: offsite_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE offsite_payments (
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

CREATE SEQUENCE offsite_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offsite_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE offsite_payments_id_seq OWNED BY offsite_payments.id;


--
-- Name: payment_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payment_imports (
    id integer NOT NULL,
    user_id integer,
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_imports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_imports_id_seq OWNED BY payment_imports.id;


--
-- Name: payment_payouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payment_payouts (
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

CREATE SEQUENCE payment_payouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_payouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_payouts_id_seq OWNED BY payment_payouts.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payments (
    id integer NOT NULL,
    gross_amount integer,
    refund_total integer,
    fee_total integer,
    net_amount integer,
    nonprofit_id integer,
    supporter_id integer,
    towards character varying(255),
    kind character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    donation_id integer,
    date timestamp without time zone,
    search_vectors tsvector
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: payouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payouts (
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

CREATE SEQUENCE payouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payouts_id_seq OWNED BY payouts.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE profiles (
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

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: recurring_donations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE recurring_donations (
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
    anonymous boolean,
    donation_id integer,
    n_failures integer,
    cancelled_by character varying(255),
    cancelled_at timestamp without time zone
);


--
-- Name: recurring_donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recurring_donations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurring_donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recurring_donations_id_seq OWNED BY recurring_donations.id;


--
-- Name: refunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE refunds (
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

CREATE SEQUENCE refunds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refunds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE refunds_id_seq OWNED BY refunds.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roles (
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

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: source_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE source_tokens (
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
-- Name: supporter_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE supporter_emails (
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

CREATE SEQUENCE supporter_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporter_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supporter_emails_id_seq OWNED BY supporter_emails.id;


--
-- Name: supporter_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE supporter_notes (
    id integer NOT NULL,
    content text,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    deleted boolean
);


--
-- Name: supporter_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supporter_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporter_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supporter_notes_id_seq OWNED BY supporter_notes.id;


--
-- Name: supporters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE supporters (
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
    anonymous boolean,
    zip_code character varying(255),
    latitude double precision,
    longitude double precision,
    full_contact_info_id integer,
    deleted boolean DEFAULT false,
    organization character varying(255),
    imported_at timestamp without time zone,
    country character varying(255) DEFAULT 'United States'::character varying,
    import_id integer,
    email_unsubscribe_uuid character varying(255),
    is_unsubscribed_from_emails boolean,
    search_vectors tsvector,
    merged_into integer,
    merged_at timestamp without time zone,
    region character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    locale character varying(255)
);


--
-- Name: supporters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supporters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supporters_id_seq OWNED BY supporters.id;


--
-- Name: tag_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tag_joins (
    id integer NOT NULL,
    tag_master_id integer,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tag_joins_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tag_joins_backup (
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

CREATE SEQUENCE tag_joins_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_joins_backup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_joins_backup_id_seq OWNED BY tag_joins_backup.id;


--
-- Name: tag_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_joins_id_seq OWNED BY tag_joins.id;


--
-- Name: tag_masters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tag_masters (
    id integer NOT NULL,
    name character varying(255),
    nonprofit_id integer,
    deleted boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tag_masters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_masters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_masters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_masters_id_seq OWNED BY tag_masters.id;


--
-- Name: ticket_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ticket_levels (
    id integer NOT NULL,
    event_id integer,
    amount integer,
    quantity integer,
    name character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted boolean,
    "limit" integer,
    event_discount_id integer,
    admin_only boolean,
    "order" integer
);


--
-- Name: ticket_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ticket_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ticket_levels_id_seq OWNED BY ticket_levels.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tickets (
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
    deleted boolean,
    source_token_id uuid
);


--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tickets_id_seq OWNED BY tickets.id;


--
-- Name: trackings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE trackings (
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

CREATE SEQUENCE trackings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trackings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trackings_id_seq OWNED BY trackings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
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

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: bank_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts ALTER COLUMN id SET DEFAULT nextval('bank_accounts_id_seq'::regclass);


--
-- Name: billing_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_plans ALTER COLUMN id SET DEFAULT nextval('billing_plans_id_seq'::regclass);


--
-- Name: billing_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_subscriptions ALTER COLUMN id SET DEFAULT nextval('billing_subscriptions_id_seq'::regclass);


--
-- Name: campaign_gift_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_gift_options ALTER COLUMN id SET DEFAULT nextval('campaign_gift_options_id_seq'::regclass);


--
-- Name: campaign_gifts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_gifts ALTER COLUMN id SET DEFAULT nextval('campaign_gifts_id_seq'::regclass);


--
-- Name: campaign_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_templates ALTER COLUMN id SET DEFAULT nextval('campaign_templates_id_seq'::regclass);


--
-- Name: campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaigns ALTER COLUMN id SET DEFAULT nextval('campaigns_id_seq'::regclass);


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards ALTER COLUMN id SET DEFAULT nextval('cards_id_seq'::regclass);


--
-- Name: charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY charges ALTER COLUMN id SET DEFAULT nextval('charges_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: custom_field_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_field_joins ALTER COLUMN id SET DEFAULT nextval('custom_field_joins_id_seq'::regclass);


--
-- Name: custom_field_joins_backup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_field_joins_backup ALTER COLUMN id SET DEFAULT nextval('custom_field_joins_backup_id_seq'::regclass);


--
-- Name: custom_field_masters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_field_masters ALTER COLUMN id SET DEFAULT nextval('custom_field_masters_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: direct_debit_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_debit_details ALTER COLUMN id SET DEFAULT nextval('direct_debit_details_id_seq'::regclass);


--
-- Name: disputes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY disputes ALTER COLUMN id SET DEFAULT nextval('disputes_id_seq'::regclass);


--
-- Name: donations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY donations ALTER COLUMN id SET DEFAULT nextval('donations_id_seq'::regclass);


--
-- Name: email_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_lists ALTER COLUMN id SET DEFAULT nextval('email_lists_id_seq'::regclass);


--
-- Name: email_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_settings ALTER COLUMN id SET DEFAULT nextval('email_settings_id_seq'::regclass);


--
-- Name: event_discounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_discounts ALTER COLUMN id SET DEFAULT nextval('event_discounts_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exports ALTER COLUMN id SET DEFAULT nextval('exports_id_seq'::regclass);


--
-- Name: full_contact_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_infos ALTER COLUMN id SET DEFAULT nextval('full_contact_infos_id_seq'::regclass);


--
-- Name: full_contact_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_jobs ALTER COLUMN id SET DEFAULT nextval('full_contact_jobs_id_seq'::regclass);


--
-- Name: full_contact_orgs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_orgs ALTER COLUMN id SET DEFAULT nextval('full_contact_orgs_id_seq'::regclass);


--
-- Name: full_contact_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_photos ALTER COLUMN id SET DEFAULT nextval('full_contact_photos_id_seq'::regclass);


--
-- Name: full_contact_social_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_social_profiles ALTER COLUMN id SET DEFAULT nextval('full_contact_social_profiles_id_seq'::regclass);


--
-- Name: full_contact_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_topics ALTER COLUMN id SET DEFAULT nextval('full_contact_topics_id_seq'::regclass);


--
-- Name: image_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_attachments ALTER COLUMN id SET DEFAULT nextval('image_attachments_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY imports ALTER COLUMN id SET DEFAULT nextval('imports_id_seq'::regclass);


--
-- Name: miscellaneous_np_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY miscellaneous_np_infos ALTER COLUMN id SET DEFAULT nextval('miscellaneous_np_infos_id_seq'::regclass);


--
-- Name: nonprofit_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nonprofit_keys ALTER COLUMN id SET DEFAULT nextval('nonprofit_keys_id_seq'::regclass);


--
-- Name: nonprofits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nonprofits ALTER COLUMN id SET DEFAULT nextval('nonprofits_id_seq'::regclass);


--
-- Name: offsite_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY offsite_payments ALTER COLUMN id SET DEFAULT nextval('offsite_payments_id_seq'::regclass);


--
-- Name: payment_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_imports ALTER COLUMN id SET DEFAULT nextval('payment_imports_id_seq'::regclass);


--
-- Name: payment_payouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_payouts ALTER COLUMN id SET DEFAULT nextval('payment_payouts_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: payouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payouts ALTER COLUMN id SET DEFAULT nextval('payouts_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: recurring_donations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recurring_donations ALTER COLUMN id SET DEFAULT nextval('recurring_donations_id_seq'::regclass);


--
-- Name: refunds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY refunds ALTER COLUMN id SET DEFAULT nextval('refunds_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: supporter_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporter_emails ALTER COLUMN id SET DEFAULT nextval('supporter_emails_id_seq'::regclass);


--
-- Name: supporter_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporter_notes ALTER COLUMN id SET DEFAULT nextval('supporter_notes_id_seq'::regclass);


--
-- Name: supporters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporters ALTER COLUMN id SET DEFAULT nextval('supporters_id_seq'::regclass);


--
-- Name: tag_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_joins ALTER COLUMN id SET DEFAULT nextval('tag_joins_id_seq'::regclass);


--
-- Name: tag_joins_backup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_joins_backup ALTER COLUMN id SET DEFAULT nextval('tag_joins_backup_id_seq'::regclass);


--
-- Name: tag_masters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_masters ALTER COLUMN id SET DEFAULT nextval('tag_masters_id_seq'::regclass);


--
-- Name: ticket_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ticket_levels ALTER COLUMN id SET DEFAULT nextval('ticket_levels_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tickets ALTER COLUMN id SET DEFAULT nextval('tickets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: billing_plans billing_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_plans
    ADD CONSTRAINT billing_plan_pkey PRIMARY KEY (id);


--
-- Name: billing_subscriptions billing_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_subscriptions
    ADD CONSTRAINT billing_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: activities campaign_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT campaign_activities_pkey PRIMARY KEY (id);


--
-- Name: comments campaign_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT campaign_comments_pkey PRIMARY KEY (id);


--
-- Name: campaign_gift_options campaign_gift_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_gift_options
    ADD CONSTRAINT campaign_gift_options_pkey PRIMARY KEY (id);


--
-- Name: campaign_gifts campaign_gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_gifts
    ADD CONSTRAINT campaign_gifts_pkey PRIMARY KEY (id);


--
-- Name: campaign_templates campaign_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_templates
    ADD CONSTRAINT campaign_templates_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: charges charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY charges
    ADD CONSTRAINT charges_pkey PRIMARY KEY (id);


--
-- Name: custom_field_joins_backup custom_field_joins_backup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_field_joins_backup
    ADD CONSTRAINT custom_field_joins_backup_pkey PRIMARY KEY (id);


--
-- Name: custom_field_joins custom_field_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_field_joins
    ADD CONSTRAINT custom_field_joins_pkey PRIMARY KEY (id);


--
-- Name: custom_field_masters custom_field_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_field_masters
    ADD CONSTRAINT custom_field_masters_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: direct_debit_details direct_debit_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_debit_details
    ADD CONSTRAINT direct_debit_details_pkey PRIMARY KEY (id);


--
-- Name: disputes disputes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disputes
    ADD CONSTRAINT disputes_pkey PRIMARY KEY (id);


--
-- Name: payment_payouts donation_disbursals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_payouts
    ADD CONSTRAINT donation_disbursals_pkey PRIMARY KEY (id);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (id);


--
-- Name: profiles donor_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT donor_profiles_pkey PRIMARY KEY (id);


--
-- Name: email_settings email_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_settings
    ADD CONSTRAINT email_settings_pkey PRIMARY KEY (id);


--
-- Name: event_discounts event_discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_discounts
    ADD CONSTRAINT event_discounts_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: full_contact_infos full_contact_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_infos
    ADD CONSTRAINT full_contact_infos_pkey PRIMARY KEY (id);


--
-- Name: full_contact_jobs full_contact_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_jobs
    ADD CONSTRAINT full_contact_jobs_pkey PRIMARY KEY (id);


--
-- Name: full_contact_orgs full_contact_orgs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_orgs
    ADD CONSTRAINT full_contact_orgs_pkey PRIMARY KEY (id);


--
-- Name: full_contact_photos full_contact_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_photos
    ADD CONSTRAINT full_contact_photos_pkey PRIMARY KEY (id);


--
-- Name: full_contact_social_profiles full_contact_social_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_social_profiles
    ADD CONSTRAINT full_contact_social_profiles_pkey PRIMARY KEY (id);


--
-- Name: full_contact_topics full_contact_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_contact_topics
    ADD CONSTRAINT full_contact_topics_pkey PRIMARY KEY (id);


--
-- Name: image_attachments image_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_attachments
    ADD CONSTRAINT image_attachments_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: email_lists mailchimp_email_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_lists
    ADD CONSTRAINT mailchimp_email_lists_pkey PRIMARY KEY (id);


--
-- Name: miscellaneous_np_infos miscellaneous_np_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY miscellaneous_np_infos
    ADD CONSTRAINT miscellaneous_np_infos_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts nonprofit_bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT nonprofit_bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: payouts nonprofit_credits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payouts
    ADD CONSTRAINT nonprofit_credits_pkey PRIMARY KEY (id);


--
-- Name: nonprofit_keys nonprofit_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nonprofit_keys
    ADD CONSTRAINT nonprofit_keys_pkey PRIMARY KEY (id);


--
-- Name: nonprofits npos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nonprofits
    ADD CONSTRAINT npos_pkey PRIMARY KEY (id);


--
-- Name: offsite_payments offsite_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY offsite_payments
    ADD CONSTRAINT offsite_payments_pkey PRIMARY KEY (id);


--
-- Name: payment_imports payment_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_imports
    ADD CONSTRAINT payment_imports_pkey PRIMARY KEY (id);


--
-- Name: cards payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: recurring_donations recurring_donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recurring_donations
    ADD CONSTRAINT recurring_donations_pkey PRIMARY KEY (id);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: supporters supporter_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporters
    ADD CONSTRAINT supporter_data_pkey PRIMARY KEY (id);


--
-- Name: supporter_emails supporter_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporter_emails
    ADD CONSTRAINT supporter_emails_pkey PRIMARY KEY (id);


--
-- Name: supporter_notes supporter_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporter_notes
    ADD CONSTRAINT supporter_notes_pkey PRIMARY KEY (id);


--
-- Name: tag_joins_backup tag_joins_backup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_joins_backup
    ADD CONSTRAINT tag_joins_backup_pkey PRIMARY KEY (id);


--
-- Name: tag_joins tag_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_joins
    ADD CONSTRAINT tag_joins_pkey PRIMARY KEY (id);


--
-- Name: tag_masters tag_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_masters
    ADD CONSTRAINT tag_masters_pkey PRIMARY KEY (id);


--
-- Name: ticket_levels ticket_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ticket_levels
    ADD CONSTRAINT ticket_levels_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: trackings trackings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trackings
    ADD CONSTRAINT trackings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: custom_field_join_supporter_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX custom_field_join_supporter_unique_idx ON custom_field_joins USING btree (custom_field_master_id, supporter_id);


--
-- Name: custom_field_joins_custom_field_master_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX custom_field_joins_custom_field_master_id ON custom_field_joins USING btree (custom_field_master_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: donations_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_amount ON donations USING btree (amount);


--
-- Name: donations_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_campaign_id ON donations USING btree (campaign_id);


--
-- Name: donations_designation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_designation ON donations USING btree (lower(designation));


--
-- Name: donations_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_event_id ON donations USING btree (event_id);


--
-- Name: donations_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donations_supporter_id ON donations USING btree (supporter_id);


--
-- Name: index_activities_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_nonprofit_id ON activities USING btree (nonprofit_id);


--
-- Name: index_activities_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_supporter_id ON activities USING btree (supporter_id);


--
-- Name: index_campaign_gifts_on_campaign_gift_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_campaign_gifts_on_campaign_gift_option_id ON campaign_gifts USING btree (campaign_gift_option_id);


--
-- Name: index_cards_on_id_and_holder_type_and_holder_id_and_inactive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_id_and_holder_type_and_holder_id_and_inactive ON cards USING btree (id, holder_type, holder_id, inactive);


--
-- Name: index_charges_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_payment_id ON charges USING btree (payment_id);


--
-- Name: index_donations_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_donations_on_event_id ON public.donations USING btree (event_id);


--
-- Name: index_exports_on_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_nonprofit_id ON exports USING btree (nonprofit_id);


--
-- Name: index_exports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_user_id ON exports USING btree (user_id);


--
-- Name: index_refunds_on_charge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_refunds_on_charge_id ON public.refunds USING btree (charge_id);


--
-- Name: index_refunds_on_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_refunds_on_payment_id ON public.refunds USING btree (payment_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_source_tokens_on_expiration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_source_tokens_on_expiration ON source_tokens USING btree (expiration);


--
-- Name: index_source_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_source_tokens_on_token ON source_tokens USING btree (token);


--
-- Name: index_source_tokens_on_tokenizable_id_and_tokenizable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_source_tokens_on_tokenizable_id_and_tokenizable_type ON source_tokens USING btree (tokenizable_id, tokenizable_type);


--
-- Name: index_supporter_notes_on_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporter_notes_on_supporter_id ON public.supporter_notes USING btree (supporter_id);


--
-- Name: index_supporters_on_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporters_on_deleted ON supporters USING btree (deleted);


--
-- Name: index_supporters_on_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporters_on_import_id ON supporters USING btree (import_id);


--
-- Name: index_supporters_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supporters_on_name ON supporters USING btree (name);


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

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: payments_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_date ON payments USING btree (date);


--
-- Name: payments_donation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_donation_id ON payments USING btree (donation_id);


--
-- Name: payments_gross_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_gross_amount ON payments USING btree (gross_amount);


--
-- Name: payments_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_kind ON payments USING btree (kind);


--
-- Name: payments_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_nonprofit_id ON payments USING btree (nonprofit_id);


--
-- Name: payments_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_search_idx ON payments USING gin (search_vectors);


--
-- Name: payments_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_supporter_id ON payments USING btree (supporter_id);


--
-- Name: payments_towards; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_towards ON payments USING btree (lower((towards)::text));


--
-- Name: supporters_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_created_at ON supporters USING btree (created_at) WHERE (deleted <> true);


--
-- Name: supporters_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_email ON supporters USING btree (lower((email)::text)) WHERE (deleted <> true);


--
-- Name: supporters_general_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_general_idx ON supporters USING gin (to_tsvector('english'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || (COALESCE(email, ''::character varying))::text)));


--
-- Name: supporters_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_lower_name ON supporters USING btree (lower((name)::text)) WHERE (deleted <> true);


--
-- Name: supporters_nonprofit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_nonprofit_id ON supporters USING btree (nonprofit_id) WHERE (deleted <> true);


--
-- Name: supporters_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporters_search_idx ON supporters USING gin (search_vectors);


--
-- Name: tag_join_supporter_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tag_join_supporter_unique_idx ON tag_joins USING btree (tag_master_id, supporter_id);


--
-- Name: tag_joins_supporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tag_joins_supporter_id ON tag_joins USING btree (supporter_id);


--
-- Name: tag_joins_tag_master_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tag_joins_tag_master_id ON tag_joins USING btree (tag_master_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


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

INSERT INTO schema_migrations (version) VALUES ('20180713213748');

INSERT INTO schema_migrations (version) VALUES ('20180713215825');

INSERT INTO schema_migrations (version) VALUES ('20180713220028');

INSERT INTO schema_migrations (version) VALUES ('20181002160627');

INSERT INTO schema_migrations (version) VALUES ('20181003212559');

INSERT INTO schema_migrations (version) VALUES ('201810202124316');

INSERT INTO schema_migrations (version) VALUES ('201810202124317');

INSERT INTO schema_migrations (version) VALUES ('201810202124318');

INSERT INTO schema_migrations (version) VALUES ('201810202124319');

INSERT INTO schema_migrations (version) VALUES ('201810202124320');

INSERT INTO schema_migrations (version) VALUES ('201810202124321');

