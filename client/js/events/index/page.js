const renderListings = require('../listings')
renderListings(`/nonprofits/${app.nonprofit_id}/events/listings`)

if(app.current_user) {
  require('../../events/new/wizard')
}

