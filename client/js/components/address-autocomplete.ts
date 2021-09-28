// License: LGPL-3.0-or-later

import autocomplete_base from './address-autocomplete-base';

const flyd = require('flyd')

// Stream that has true when google script is loaded
const loaded$ = flyd.stream()


function initScript() {
  autocomplete_base.registerAutocompleteAvailableCallback(() => loaded$(true))
  autocomplete_base.startLoadingAutocomplete();
  return loaded$
}


function initInput(input:HTMLInputElement) {
  const data$ = flyd.stream();
  autocomplete_base.createAutocompleteInput({input, placeChangedCallbacks:[(place) => data$(place)]});
  return data$;
}


module.exports = {initScript, initInput, loaded$}
