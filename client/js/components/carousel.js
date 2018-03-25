const R = require('ramda')
const h = require('flimflam/h')

const setWidth = (elm, number) => 
  elm.style.width = number * elm.parentElement.offsetWidth + 'px'

const setItemsDimensions = (items, percent) => {
  const heights = R.map(x => x.offsetHeight, items)
  const tallest = R.reduce((a, b) => a >= b ? a : b  , 0, heights)
  R.map(x => {
    x.style.width = percent + '%'
    x.style.height = tallest + 'px'
  }, items)
}

const init = (count, percent) => vnode => {
  const elm = vnode.elm
  const items = elm.childNodes
  setItemsDimensions(items, percent)
  setWidth(elm, count)
  window.addEventListener('resize', () => {
    setItemsDimensions(items, percent)
    setWidth(elm, count)
  })
}

module.exports = obj => {
  const percent = 100 / obj.count
  return h('div', [
    h('div.overflow-hidden', [
      h('div.transition-slow.clearfix'
      , {
          hook: {insert: init(obj.count, percent)}
        , style: {transform: `translateZ(0) translateX(-${percent * obj.index}%)`}
        }
      , R.map(x => h('div.left.p-2.table', [h('div.middle-cell', [x])]), obj.content)
     )
    ])
  ])
}

