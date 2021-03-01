// License: LGPL-3.0-or-later
require('../../../common/restful_resource')
require('../../../common/panels_layout')
require('../../../components/date_range_picker')
require('../../../common/apply-pikaday')
require('./list_supporters')
require('./timeline')
require('./supporter_details')
require('./sidepanel')
require('./bulk_delete')
require('./manage_tags')
require('./manage_custom_fields')
require('../../../common/ajax/get_campaign_and_event_names_and_ids')(app.nonprofit_id)
require('./merge_supporters')
require('../import/index.es6')
require('../../../components/tables/filtering/apply_filter')('supporters')
require('./tour')


// Flim flam go:
require('../../../supporters')


// XXX cruft
appl.def('set_export_custom_fields', function(node) {
  var checkbox = appl.prev_elem(node)
  if (appl.supporters.query.export_custom_fields) {
    appl.supporters.query.export_custom_fields += ','
  } else {
    appl.supporters.query.export_custom_fields = ''
  }
  appl.supporters.query.export_custom_fields += checkbox.value
  appl.def('supporters.query', appl.supporters.query)
})
