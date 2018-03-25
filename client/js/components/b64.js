// see https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding
// used for encoded and decoding data for email text

module.exports = {
  encode: str => 
    btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g
      , (match, p1) => String.fromCharCode('0x' + p1))).replace(/\//g,'_').replace(/\+/g,'-')
  , decode: str => 
      decodeURIComponent(Array.prototype.map.call(atob(str.replace(/-/g, '+').replace(/_/g, '/'))
      , c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join(''))
}

