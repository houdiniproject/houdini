// License: LGPL-3.0-or-later
// This is a little utility to convert a superagent response that has an error
// into a readable single string message
//
// This should work both with 422 unprocessable entities as well as 500 server errors

module.exports = show_err

var err_msg = "We're sorry, but something went wrong. Please try again soon."

function show_err(resp) {
  console.error(resp)

  if(resp.body && resp.body.error) { return resp.body.error }
  if(resp.body && resp.body.errors && resp.body.errors.length) { return resp.body.errors[0] }
  if(resp.body) { return resp.body }
  if(resp.error) { return resp.error }
  return err_msg
}

