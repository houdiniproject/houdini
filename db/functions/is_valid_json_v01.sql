CREATE OR REPLACE FUNCTION public.is_valid_json(p_json text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
  return (p_json::json is not null);
exception
  when others then
     return false;
end;
$$;