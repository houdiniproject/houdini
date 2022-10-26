// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
declare const app: {widget?:{custom_recurring_donation_phrase?:string}} |undefined;

export default function getSustainingAmount() : any[]| string | null {

  if (app && app.widget && app.widget.custom_recurring_donation_phrase)
  {
    return [h('span', {props: {innerHTML: app.widget.custom_recurring_donation_phrase}})]
  }

  return null;
}