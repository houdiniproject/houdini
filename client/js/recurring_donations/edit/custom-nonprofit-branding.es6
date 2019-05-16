// License: LGPL-3.0-or-later
const color = require('color')

module.exports = (brand_color = null) => {
    let brandColor = brand_color || '#5FB88D'
    return {
        lightest: color(brandColor).lighten(0.8).hex()
        , lighter: color(brandColor).lighten(0.7).hex()
        , light: color(brandColor).lighten(0.5).hex()
        , base: brandColor
        , dark: color(brandColor).darken(0.1).hex()
        , darker: color(brandColor).darken(0.3).hex()
        , grey: "#636363"
        , light_grey: "rgb(248, 248, 248)"
    }
}
