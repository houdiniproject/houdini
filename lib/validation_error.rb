# A generalized, all purpose struct for database validation errors
# .errors is simply array of error messages

ValidationError = Struct.new(:errors)
