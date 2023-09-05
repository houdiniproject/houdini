// License: LGPL-3.0-or-later

export interface AmountButtonDesc {
  amount: number;
  highlight: boolean
}

type AmountButtonInput = AmountButtonDesc | number;


export default function getAmt(amt:AmountButtonInput) : AmountButtonDesc {

  if (typeof amt === 'number'){
    return {amount: amt, highlight: false}
  }
  else
    return amt;

}