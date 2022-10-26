// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
declare const app: {widget?:{postfix_element?:{type?:string, html_content?:string }}} |undefined;

export default function getPostfixElement() : any[] {

  if (app && app.widget && app.widget.postfix_element && app.widget.postfix_element.html_content)
  {
    return [
      h('section.u-paddingX--5', {
        props: {
          innerHTML: app.widget.postfix_element.html_content
        }
      })
    ]
  }

  return [];
}