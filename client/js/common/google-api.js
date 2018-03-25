const flyd = require('flyd')
const filter = require('flyd/module/filter')
const R = require('ramda')

var googz = {}

// loads client API and returns a true stream if user is already signed in
googz.init = scope => {
  if(document.getElementById('googzAuthApi')) return
  var script = document.createElement('script')
  script.type = 'text/javascript'
  script.id = 'googzAuthApi'
  document.body.appendChild(script)
  script.src = 'https://apis.google.com/js/api.js?onload=loadGoogleClientLib'

  const isSignedIn$ = flyd.stream()

  window.loadGoogleClientLib = _ => {
    gapi.load('client:auth2', _ => {
      gapi.client.setApiKey(app.google_api)
      gapi.auth2.init(
        {'client_id': app.google_auth_client_id
        , 'scope': scope}
      ).then(_ => {
        isSignedIn$(gapi.auth2.getAuthInstance().isSignedIn.get())
      })
    }) 
  }
  return isSignedIn$
}

// returns a stream that will have a value once the user has signed in
googz.signIn = _ => {
  const isSigningIn$ = flyd.stream()
  gapi.auth2.getAuthInstance().signIn().then(isSigningIn$)
  return isSigningIn$
}

// returns a stream with the email of the signed in user
googz.email = _ => {
  const email$ = flyd.stream()
  var profile = gapi.auth2.getAuthInstance()
  var email = profile.currentUser.get().getBasicProfile().getEmail()
  return email$(email)
}

module.exports = googz

