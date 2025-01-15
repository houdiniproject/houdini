// License: LGPL-3.0-or-later
/**
 * 
 * @param {string} str 
 * @returns {string} a sanitized string
 */
module.exports = str =>
 str.trim().toLowerCase()
  .replace(/\s*[^A-Za-z0-9\-]\s*/g, '-') // Replace any oddballs with a hyphen
  .replace(/-+$/g,'').replace(/^-+/, '').replace(/-+/, '-') // Remove starting/trailing and repeated hyphens
