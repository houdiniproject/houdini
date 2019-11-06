// License: LGPL-3.0-or-later

const gradient = require('../../common/css-gradient')
const customBranding = require('./custom-nonprofit-branding.es6')

const bg = color => `background-color: ${color} !important;`

module.exports = function (brand_color = null) {
    var colors = customBranding(brand_color)

          return   `
.wizard-steps div.is-selected, 
.wizard-steps button.is-selected {
  ${bg(colors.lighter)}
}
.wizard-steps .button.white {
  color: #494949;
}
.wizard-steps a:not(.button--small),
.ff-wizard-index-label.ff-wizard-index-label--accessible,
.wizard-index-label.is-accessible {
  color: ${colors.dark} !important;
}
.wizard-steps input.is-selected {
  border-color: ${colors.light} !important;
}
.wizard-steps button:not(.white):not([disabled]) {
  ${bg(colors.dark)}
} 
.wizard-steps .highlight {
  ${bg(colors.lightest)}
}
.wizard-steps label, 
.wizard-steps th {
  color: #636363;
}

.wizard-steps input[type='radio']:checked + label:before {
  ${bg(colors.base)}
}

.wizard-steps input[type='checkbox'] + label:before {
  color: ${colors.base} !important;
}

.ff-wizard-index-label.ff-wizard-index-label--current,
.wizard-index-label.is-current {
  ${gradient('left', '#fbfbfb', colors.light)}
}
`
}
