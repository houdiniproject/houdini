// License: LGPL-3.0-or-later
/**
 * 
 * @param {{quantity?:undefined} | {quantity:number, total_gifts:number}} g 
 * @returns {boolean}
 */
module.exports = g => g.quantity && (g.quantity - g.total_gifts <= 0)

