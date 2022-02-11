CREATE OR REPLACE FUNCTION public.update_fts_on_donations() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.comment, ''));
          RETURN new;
        END
      $$;