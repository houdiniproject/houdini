CREATE TRIGGER update_donations_fts BEFORE INSERT OR UPDATE ON public.donations FOR EACH ROW EXECUTE FUNCTION public.update_fts_on_donations();