# ParamValidation

A standalone and simple ruby hash validation lib, useful for validating the data passed to your functions. 

```rb
new_charge_validation = {
  amount: {
    required: true
  },
  stripe_card_token: {
    required: true,
    format: /^tok_.*$/
  }
}

def update_database(data)
  ParamValidation.new(data, new_charge_validation)
  # do stuff
  return result
end
```

The above checks the `:amount` and `:stripe_card_token` keys inside the `data`
hash and runs validations on them. If a value is invalid, an exception is
thrown. The exception can be handled outside your function call, typically in a
controller/router or in a test suite.

An exception is thrown for each failure.

## ParamValidation::Error

The ParamValidation::Error object has the following information on it:

```rb
begin 
  update_database(data)
rescue ParamValidation::Error => e
  e.message # string validation failure message
  e.val     # value that failed validation
  e.key     # key name of the above value inside the data hash
  e.name    # name of the validator that failed
rescue Exception => e
  # a non-validation exception
end
```

## Using in Rails

To handle validation exceptions from the controller, you can add a custom helper function in your ApplicationController like this:

```rb
def render_json(&block)
  begin
    result = yield block
  rescue ParamValidation::Error => e
    return {status: 422, json: {error: e.message, key: e.key}}
  rescue Error => e # a non-validation related exception
    return {status: 500, json: e}
  end
  return {status: 200, json: result}
end
```

With the above, you can simply call render_json on your validated function call:

```rb
UsersController < ApplicationController
  def update
    render_json{ update_user(params[:user]) }
  end
end
```

```rb
update_validation = {
  email: {
    presence: :optional,
    format: email_regex
  }
}

def update_user(params)
  ParamValidation.new(params, update_validation)
end
```

### built-in validators

- required: value must be non-nil
- absent: value must be nil
- not_included_in: value must not be in array
- included_in: value must be in array
- format: value must match regex
- is_integer: value must look like an integer (can be a string)
- is_float: value must look like a float (can be a string)
- min_length: array value must have length >= min
- max_length: array value must have length <= max
- length_range: array value must have length within given range
- length_equals: array value length must equal given arg
- equals: value must equal given arg
- min: value must be >= arg
- max: value must be <= arg
- in_range: value must be within the given range

### custom validators

ParamValidation.add_validator takes a name and a block. That block performs the
validations and simply returns true/false. The block takes three params: the
actual value to validate, and the argument provided in the validation hash, and
the entire data hash being validated.

```rb
# You can use other validators inside a new validator
ParamValidation.add_validator(:dollars) do |val, arg, data|
  ParamValidation.validators[:format](val, /^\$\d+\.(\d\d)$?, data)
end

# # Validators that don't need an argument typically just get 'true' passed in
# ParamValidation.new(params, { 
#   amount: { dollars: true }
# })

# Other examples

# Uniqueness validation (of course it may be better to use the UNIQUE constraint in sql)
ParamValidation.add_validator(:unique) do |val, arg, data|
  Qx.select("COUNT(*)").from(:table).where(name: val).first['count'] == 0
end
```

### custom validation messages

Within a validation instance, you can set a custom message with the :message key.

```rb
ParamValidation.new(params, {
  amount: {
    dollars: true,
    message: 'Please enter a dollar amount'
  }
})
```

To change the global default message, simply use ParamValidation.set_message(:validation_name, &block).

```rb
ParamValidation.set_message(:dollars) do |h|
  "#{h[:key]} must be in dollars"
end
```

The `set_message` block receives a hash with some data:

* :key  - name of the key in the hash that failed this validation
* :arg  - argument to validator (eg format regex)
* :val  - actual value that failed validation
* :data - entire data hash that is being validated


#### internationalization -- TODO!

Internationalization support is not yet in place; please make a PR for it!
