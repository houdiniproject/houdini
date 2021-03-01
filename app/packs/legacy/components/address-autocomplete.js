// License: LGPL-3.0-or-later
const R = require('ramda')
const flyd = require('flyd')

// Stream that has true when google script is loaded
const loaded$ = flyd.stream()
// Stream of autocomplete data
const data$ = flyd.stream()

function initScript() {
  // if(document.getElementById('googleAutocomplete')) return
  // var script = document.createElement('script')
  // script.type = 'text/javascript'
  // script.id = 'googleAutocomplete'
  // document.body.appendChild(script)
  // script.src = `https://maps.googleapis.com/maps/api/js?key=${app.google_api}&libraries=places&callback=initGoogleAutocomplete`
  return loaded$
}

window.initGoogleAutocomplete = () => loaded$(true)

function initInput(input) {
  var autocomplete = new google.maps.places.Autocomplete(input, {types: ['geocode']})
  autocomplete.addListener('place_changed', fillInAddress(autocomplete))
  input.addEventListener('focus', geolocate(autocomplete))
  input.addEventListener('keydown', e => { if(e.which === 13) e.preventDefault() })
  return data$
}

const acceptedTypes = {
  street_number: 'short_name'
, route: 'long_name'
, locality: 'long_name'
, administrative_area_level_1: 'short_name'
, country: 'long_name'
, postal_code: 'short_name'
}

const fillInAddress = autocomplete => () => {
  var place = { components: autocomplete.getPlace().address_components}
  if(!place.components) return
  place.types = R.map(x => x.types[0], place.components)
  var address = placeData(place, 'street_number')
    ? placeData(place, 'street_number') + ' ' + placeData(place, 'route')
    : ''

  var data = {
    address: address
  , city: placeData(place, 'locality')
  , state_code: placeData(place, 'administrative_area_level_1')
  , country: placeData(place, 'country')
  , zip_code: placeData(place, 'postal_code')
  }
  data$(data)
}

function placeData(place, key) {
  const i = R.findIndex(R.equals(key), place.types)
  if(i >= 0) return place.components[i][acceptedTypes[key]]
  return ''
}

// Bias the autocomplete object to the user's geographical location,
// as supplied by the browser's 'navigator.geolocation' object.
const geolocate = autocomplete => () => {
  if(!navigator || !navigator.geolocation) return
  navigator.geolocation.getCurrentPosition(pos => {
    var geolocation = {
      lat: pos.coords.latitude
    , lng: pos.coords.longitude
    }
    var circle = new google.maps.Circle({
      center: geolocation
    , radius: pos.coords.accuracy
    })
    autocomplete.setBounds(circle.getBounds())
  })
}


module.exports = {initScript, initInput, data$, loaded$}
