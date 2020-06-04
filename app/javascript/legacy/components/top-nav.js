// License: LGPL-3.0-or-later
const h = require('flimflam/h')

module.exports = title => 
  h('div.bg-grey-2', [
    h('div.container.px-2.py-1.table.width-full', [
      h('h4.m-0.middle-cell.py-1', title)
    // , h('div.middle-cell.content-width.color-blue', [
    //     h('i.h3.m-icon.middle-cell', 'account_circle')
    //   , h('small.middle-cell.px-1', 'Nonprofit name')
    //   , h('i.h4.m-icon.middle-cell', 'keyboard_arrow_down')
    //   ])
    ])
  ])

