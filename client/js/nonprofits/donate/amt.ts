// License: LGPL-3.0-or-later
export default function getAmt(amt:number|{amount:number, highlight:boolean}) : {amount:number, highlight:boolean} {

  if (typeof amt === 'number'){
    return {amount: amt, highlight: false}
  }
  else
    return amt;

}