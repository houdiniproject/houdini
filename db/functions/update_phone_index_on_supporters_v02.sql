CREATE OR REPLACE FUNCTION public.update_phone_index_on_supporters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
              new.phone_index = (regexp_replace(new.phone, '\D','', 'g'));
              RETURN new;
            END
          $$;