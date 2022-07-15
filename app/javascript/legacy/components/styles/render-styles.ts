// License: LGPL-3.0-or-later
module.exports = _ => {
  var styleTag = document.createElement('style')
  return styles => {
    styleTag.innerHTML = styles
    document.querySelector('head').appendChild(styleTag)
  }
}

