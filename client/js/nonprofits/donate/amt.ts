// License: LGPL-3.0-or-later

export interface AmountButtonDesc {
  amount: number;
  highlight: string | false;
}

type AmountButtonInput = {
  amount: number;
  highlight: string | boolean;
} | number;


export default function getAmt(amt:AmountButtonInput) : AmountButtonDesc {

  if (typeof amt === 'number'){
    return {amount: amt, highlight: false}
  }
  else {
    return {amount:amt.amount, highlight: amt.highlight === true ? 'star' : amt.highlight}
  }

}