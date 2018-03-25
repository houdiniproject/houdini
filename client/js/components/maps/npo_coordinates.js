module.exports = function(){
	if(app.nonprofit.latitude) {
		return {
			lat: app.nonprofit.latitude,
			lng: app.nonprofit.longitude,
		}
	}
}
