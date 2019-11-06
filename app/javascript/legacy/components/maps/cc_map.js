// License: LGPL-3.0-or-later
var request = require('../../common/client')
var map_options = require('./default_options')
var cc_map = {}
var info_window = false
var map_data

// the endpoint is the only required param
// see maps_controller for endpoint options
cc_map.init = function(endpoint, options_obj, query) {
	endpoint = window.location.origin + '/maps/' + endpoint
	request.get(endpoint)
		.query(query)
		.end(function(err, resp) {
			map_data = resp.body.data
			var has_map = document.getElementById('google_maps')
			if (app.map_provider === 'google') {
                if (!has_map) {
                    var script = document.createElement('script')
                    script.type = 'text/javascript'
                    script.id = 'google_maps'
										let key = ""
										if (app.map_provider_options && app.map_provider_options.key) {
                      key = `key=${app.map_provider_options.key}&`
                    }
                    script.src = `https://maps.googleapis.com/maps/api/js?${key}callback=draw_map`
                    document.body.appendChild(script)
                    set_extra_options(options_obj)
                } else {
                    set_extra_options(options_obj)
                    draw_map()
                }
            }
            else {
                if (has_map)
				{
					has_map.innerText = "Sorry, no map provider is installed"
				}
				else
				{
                    var map = document.getElementById('googleMap')
                    map.innerText = "Sorry, no map provider is installed"
				}
			}
	})
}


function set_extra_options(obj){
	if(!obj){
		return
	}
	if(obj.center && obj.center.lat) {
		map_options.lat = obj.center.lat
		map_options.lng = obj.center.lng
	}
	map_options.disableDefaultUI = obj.disable_ui ? true : false
	map_options.zoom = obj.zoom ? obj.zoom : map_options.zoom
	map_options.fit_all = obj.fit_all ? true : false
}


window.draw_map = function () {
	map_options.center = new google.maps.LatLng(map_options.lat, map_options.lng)
	map_options.mapTypeId = google.maps.MapTypeId.NORMAL
  var map = new google.maps.Map(document.getElementById('googleMap'), map_options)
  add_markers(map)
}


function add_markers(map){
	var markers = []
	appl.def('map_data_count', map_data.length)
	map_data.forEach(function(data){
			if (!data.latitude) {
				return
			}
			var coordinates = new google.maps.LatLng(data.latitude, data.longitude)
			var marker = new google.maps.Marker({
			position: coordinates,
			map: map,
			draggable: false,
			icon: 'https://raw.githubusercontent.com/CommitChange/public-resources/master/images/cc-map-marker-pick-22.png',
			data: data
		})

		google.maps.event.addListener(marker, 'click', function() {
			if (info_window) {
				info_window.close()
			}
			info_window = new google.maps.InfoWindow({ content: this.data.name })
			info_window.open(map,this)
			var map_data = this.data
			if(map_data.total_raised) {
				map_data.total_raised = utils.cents_to_dollars(map_data.total_raised)
			}
			appl.def('map_data', map_data)
		})
		markers.push(marker)
	})
	if(map_options.fit_all) {
		var bounds = new google.maps.LatLngBounds();
		for(var i = 0; i < markers.length; i++) {
		 bounds.extend(markers[i].getPosition());
		}
		map.fitBounds(bounds);
	}
}

module.exports = cc_map
