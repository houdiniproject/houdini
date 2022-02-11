CREATE OR REPLACE FUNCTION public.update_fts_on_supporters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.name, '') || ' ' || coalesce(new.email, '') || ' ' || coalesce(new.organization, ''));
          RETURN new;
        END
      $$;