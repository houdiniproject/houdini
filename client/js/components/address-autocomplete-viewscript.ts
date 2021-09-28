// License: LGPL-3.0-or-later

import autocomplete_base from './address-autocomplete-base';
declare const app: any;

function initScript() {
  autocomplete_base.startLoadingAutocomplete();
}



module.exports = {initScript}
