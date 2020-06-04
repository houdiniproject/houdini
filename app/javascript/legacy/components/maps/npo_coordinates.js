// License: LGPL-3.0-or-later
module.exports = function(){
	if(app.nonprofit.latitude) {
		return {
			lat: app.nonprofit.latitude,
			lng: app.nonprofit.longitude,
		}
	}
}
