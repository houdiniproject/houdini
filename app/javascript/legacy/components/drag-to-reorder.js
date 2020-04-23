// License: LGPL-3.0-or-later
const dragula = require('dragula')
const serialize = require('form-serialize')
const R = require('ramda')
const request = require('../common/request')
const flyd = require('flyd')
const flatMap = require('flyd/module/flatmap')

const mapIndex = R.addIndex(R.map)

module.exports = function(path, containerId, afterUpdateFunction) {

  // Stream of dragged elements
  const draggedEls$ = flyd.stream()
 
  dragula([document.getElementById(containerId)]).on('dragend', draggedEls$)

  // Make a stream of objects with .id and .order
  const giftOptions$ = flyd.map( getIdAndOrder , draggedEls$)

  function getIdAndOrder(el) {
    var form = el.querySelector('input').form
    var ids = serialize(form, {hash: true}).id
    return {data: mapIndex((v, i) => ({id: v, order: i}), ids)}
  }

  const updateOrdering = send => flyd.map(R.prop('body'), request({path, method: 'put' , send}).load)

  const response$ = flatMap(updateOrdering, giftOptions$) 

  // Optional after update function 
  if(afterUpdateFunction) {
    flyd.map(afterUpdateFunction, response$)
  }
}


