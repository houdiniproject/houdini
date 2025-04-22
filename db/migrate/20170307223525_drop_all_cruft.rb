# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DropAllCruft < ActiveRecord::Migration
  def change
    Qx.execute(%(
      DROP FUNCTION IF EXISTS update_payment_donations_search_vectors();
      DROP FUNCTION IF EXISTS supporters_insert_trigger();
      DROP FUNCTION IF EXISTS update_payment_search_vectors();
      DROP FUNCTION IF EXISTS update_payment_supporters_search_vectors();
      DROP FUNCTION IF EXISTS update_supporter_search_vectors();
      DROP TABLE IF EXISTS billing_customers;
      DROP TABLE IF EXISTS coupons;
      DROP TABLE IF EXISTS dedications;
      DROP TABLE IF EXISTS email_drafts;
      DROP TABLE IF EXISTS image_points;
      DROP TABLE IF EXISTS pg_search_documents;
      DROP TABLE IF EXISTS prospect_events;
      DROP TABLE IF EXISTS prospect_visit_params;
      DROP TABLE IF EXISTS prospect_visits;
      DROP TABLE IF EXISTS prospects;
      DROP TABLE IF EXISTS recommendations;
    ))
  end

  def down
    Qx.execute(%(
CREATE FUNCTION update_payment_donations_search_vectors() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
      IF pg_trigger_depth() <> 1 THEN RETURN new; END IF;
      UPDATE payments
        SET search_vectors=to_tsvector('english', data.search_blob)
        FROM (
SELECT payments.id, concat_ws(' '
        , payments.gross_amount
        , payments.kind
        , payments.towards
        , supporters.name
        , supporters.organization
        , supporters.email
        , supporters.city
        , supporters.state_code
        , donations.designation
        , donations.dedication
        ) AS search_blob
FROM payments
LEFT OUTER JOIN supporters
  ON payments.supporter_id=supporters.id
LEFT OUTER JOIN donations
  ON payments.donation_id=donations.id
WHERE (payments.donation_id=NEW.id)) AS data
        WHERE data.id=payments.id;
      RETURN new;
    END $$;
    ))

    Qx.execute(%(
CREATE FUNCTION supporters_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO supporters_active VALUES(NEW.*);
    RETURN NULL;
  END; $$;
))

    Qx.execute(%(
CREATE FUNCTION update_payment_search_vectors() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
      IF pg_trigger_depth() <> 1 THEN RETURN new; END IF;
      UPDATE payments
        SET search_vectors=to_tsvector('english', data.search_blob)
        FROM (
SELECT payments.id, concat_ws(' '
        , payments.gross_amount
        , payments.kind
        , payments.towards
        , supporters.name
        , supporters.organization
        , supporters.email
        , supporters.city
        , supporters.state_code
        , donations.designation
        , donations.dedication
        ) AS search_blob
FROM payments
LEFT OUTER JOIN supporters
  ON payments.supporter_id=supporters.id
LEFT OUTER JOIN donations
  ON payments.donation_id=donations.id
WHERE (payments.id=NEW.id)) AS data
        WHERE data.id=payments.id;
      RETURN new;
    END $$;

    ))

    Qx.execute(%(
CREATE FUNCTION update_payment_supporters_search_vectors() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
      IF pg_trigger_depth() <> 1 THEN RETURN new; END IF;
      UPDATE payments
        SET search_vectors=to_tsvector('english', data.search_blob)
        FROM (
SELECT payments.id, concat_ws(' '
        , payments.gross_amount
        , payments.kind
        , payments.towards
        , supporters.name
        , supporters.organization
        , supporters.email
        , supporters.city
        , supporters.state_code
        , donations.designation
        , donations.dedication
        ) AS search_blob
FROM payments
LEFT OUTER JOIN supporters
  ON payments.supporter_id=supporters.id
LEFT OUTER JOIN donations
  ON payments.donation_id=donations.id
WHERE (payments.supporter_id=NEW.id)) AS data
        WHERE data.id=payments.id;
      RETURN new;
    END $$;
    ))

    Qx.execute(%(
CREATE FUNCTION update_supporter_search_vectors() RETURNS trigger
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
WHERE (supporters.id=NEW.id)) AS data
        WHERE data.id=supporters.id;
      RETURN new;
    END $$;
    ))

    Qx.execute(%(
CREATE TABLE billing_customers (
    id integer NOT NULL,
    card_name character varying(255),
    stripe_customer_id character varying(255),
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

    ))

    Qx.execute(%(
CREATE TABLE coupons (
    id integer NOT NULL,
    name character varying(255),
    paid boolean,
    victim_np_id integer,
    nonprofit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
    ))

    Qx.execute(%(
CREATE TABLE dedications (
    id integer NOT NULL,
    donation_id integer,
    supporter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
    ))

    Qx.execute(%(
CREATE TABLE email_drafts (
    id integer NOT NULL,
    nonprofit_id integer,
    name character varying(255),
    value text,
    deleted boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
    ))

    Qx.execute(%(
CREATE TABLE image_points (
    id integer NOT NULL,
    image_name character varying(255),
    host_id integer,
    host_type character varying(255),
    x double precision,
    y double precision,
    preview_left character varying(255),
    preview_top character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
    ))

    Qx.execute(%(
CREATE TABLE pg_search_documents (
    id integer NOT NULL,
    content text,
    searchable_id integer,
    searchable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

    ))

    Qx.execute(%(
CREATE TABLE prospect_events (
    id integer NOT NULL,
    event character varying(255),
    prospect_visit_id integer,
    prospect_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
    ))

    Qx.execute(%(
CREATE TABLE prospect_visit_params (
    id integer NOT NULL,
    key character varying(255),
    val character varying(255),
    prospect_visit_id integer
);
    ))

    Qx.execute(%(
CREATE TABLE prospect_visits (
    id integer NOT NULL,
    pathname text,
    prospect_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
))

    Qx.execute(%(
    CREATE TABLE prospects (
    id integer NOT NULL,
    ip_address character varying(255),
    referrer_url text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying(255),
    session_id character varying(255),
    cookie_id character varying(255)
);
               ))

    Qx.execute(%(
CREATE TABLE recommendations (
    id integer NOT NULL,
    nonprofit_id integer,
    profile_id integer,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
               ))
  end
end
