// License: LGPL-3.0-or-later
import get = require('lodash/get');
declare const app:{google_api: string};

declare const window: Window & { googleAutocomplete: GoogleAutocompleteObject }

const acceptedTypes = {
  street_number: 'short_name'
  , route: 'long_name'
  , locality: 'long_name'
  , administrative_area_level_1: 'short_name'
  , country: 'long_name'
  , postal_code: 'short_name'
}

interface AutocompletePlaceData {
  address: string
  city: string
  state_code: string
  country: string
  zip_code: string
}


class GoogleAutocompleteObject {
  constructor() {
    this.initGoogleAutocomplete.bind(this);
  }
  private _loaded: boolean = false;
  private autocompleteLoadedCallbacks:Array<() => void> = []

  /**
   * Is the the Google Autocomplete script loaded
   */
  get loaded():boolean {
    return this._loaded;
  }

  public startLoadingAutocomplete():void {
    if(document.getElementById('googleAutocomplete')) return
    const script = document.createElement('script')
    script.type = 'text/javascript'
    script.id = 'googleAutocomplete'
    script.setAttribute('async', '');
    document.body.appendChild(script);
    script.src = `https://maps.googleapis.com/maps/api/js?key=${app.google_api}&libraries=places&callback=googleAutocomplete.initGoogleAutocomplete`
  }

  initGoogleAutocomplete() {
    console.log('Google Maps loaded')
    this._loaded = true
    let callback = this.autocompleteLoadedCallbacks.pop()
    while (callback ) {
      callback();
      callback = this.autocompleteLoadedCallbacks.pop();
    }
  }

  public registerAutocompleteAvailableCallback(callback: () => void): void {
    if (this.loaded) {
      callback()
    }
    else {
      this.autocompleteLoadedCallbacks.push(callback)
    }
  }

  public createAutocompleteInput(props:{input:HTMLInputElement, placeChangedCallbacks:((place: AutocompletePlaceData) => void)[]}): GoogleAutocompleteInstance {
    return new GoogleAutocompleteInstance({...props, object:this})
  }
}

interface PlaceType { components: google.maps.GeocoderAddressComponent[], types: string[] }

interface AutocompleteInstanceConstructorProps {
  input: HTMLInputElement
  object?: GoogleAutocompleteObject
  placeChangedCallbacks: ((place: AutocompletePlaceData) => void)[]
}

class GoogleAutocompleteInstance {
  inner: google.maps.places.Autocomplete
  input: HTMLInputElement;
  placeChangedCallbacks: ((place: AutocompletePlaceData) => void)[]

  constructor({ placeChangedCallbacks, object, input }: AutocompleteInstanceConstructorProps) {
    this.input = input;

    object = object || window.googleAutocomplete
    this.placeChangedCallbacks = placeChangedCallbacks || [];

    this.initInput.bind(this);
    this.handleBeforePlaceChanged.bind(this);
    this.geolocate.bind(this);

    object.registerAutocompleteAvailableCallback(() => {
      this.initInput();
    })
  }

  private initInput() {
    this.inner = new google.maps.places.Autocomplete(this.input, { types: ['geocode'] })
    this.inner.addListener('place_changed', () => this.handleBeforePlaceChanged())
    this.input.addEventListener('focus',  () => this.geolocate())
    this.input.addEventListener('keydown', e => { if (e.which === 13) e.preventDefault() })
  }

  private onPlaceChanged(place: AutocompletePlaceData) {
    this.placeChangedCallbacks.forEach((i) => i(place))
  }

  private handleBeforePlaceChanged() {
    const place:PlaceType = { components: this.inner.getPlace().address_components, types: [] }
    if (!place.components) return
    place.types = place.components.map(i => i.types[0]);

    const address = this.getPlaceData(place, 'street_number')
      ? this.getPlaceData(place, 'street_number') + ' ' + this.getPlaceData(place, 'route')
      : ''

    const data: AutocompletePlaceData = {
      address: address
      , city: this.getPlaceData(place, 'locality')
      , state_code: this.getPlaceData(place, 'administrative_area_level_1')
      , country: this.getPlaceData(place, 'country')
      , zip_code: this.getPlaceData(place, 'postal_code')
    }

    this.onPlaceChanged(data);
  }

  private getPlaceData(place: PlaceType, key: string): string {
    const i = place.types.indexOf(key)
    if (i >= 0) {
      return get(place.components[i], get(acceptedTypes, key) as string) as string;
    }
    return ''
  }

  private geolocate() {

    if (!navigator || !navigator.geolocation) return
    navigator.geolocation.getCurrentPosition(pos => {
      const geolocation = {
        lat: pos.coords.latitude
        , lng: pos.coords.longitude
      }
      const circle = new google.maps.Circle({
        center: geolocation
        , radius: pos.coords.accuracy
      })
      this.inner.setBounds(circle.getBounds())
    })
  }

}

const rootGoogleAutocomplete = new GoogleAutocompleteObject();

window.googleAutocomplete = rootGoogleAutocomplete;

export default rootGoogleAutocomplete;
