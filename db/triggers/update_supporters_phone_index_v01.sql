CREATE TRIGGER update_supporters_phone_index BEFORE INSERT OR UPDATE ON supporters FOR EACH ROW EXECUTE FUNCTION update_phone_index_on_supporters();