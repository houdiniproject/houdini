// License: LGPL-3.0-or-later
var request = require('../../common/client')

module.exports = function(url, type) {
  appl.def('toggle_soft_delete', function(bool) {
    appl.def('loading', true)
    var action =  bool ? 'deleted.' :  'undeleted.'
    request.put(url + '/soft_delete', {delete: bool}).end(function(err, resp) {
      appl.def('loading', false)
        .def(type + '_is_deleted', bool)
        .notify('Successfully ' + action)
        .close_modal()
  	})
  })
}
