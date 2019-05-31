import { boundMethod } from "autobind-decorator";

// License: LGPL-3.0-or-later
// from: https://github.com/jsillitoe/react-currency-input/blob/master/src/mask.js


interface MaskedAndRawValues {
  value: number,
  maskedValue: string
};



export class NumberFormatHelper  {
  
  constructor(readonly numberFormat: Intl.NumberFormat) {}

  static initializeFromProps(locales?: string | string[], options?: Intl.NumberFormatOptions) : NumberFormatHelper
  {
    return new NumberFormatHelper(new Intl.NumberFormat(locales, options))
  }

  @boundMethod
  mask(value?: number | string): MaskedAndRawValues {
    if (value === null || value === undefined) {
      return {
        value: 0,
        maskedValue: ''
      };
    }

    if (typeof value === 'number') {
      return {
        value: value,
        maskedValue: this.numberFormat.format(value)
      }
    }
    else {
      if (value === '') {
        return {
          value: 0,
          maskedValue: ''
        };
      }

      const decimal = this.getDecimalSeparator()
      let decimalRegexpString = "\\d"
      const hasDecimalSeparator = decimal && decimal != '';
      if (hasDecimalSeparator) {
        decimalRegexpString += "|["+ decimal + "]"
      }
      const decimalRegexp = new RegExp(decimalRegexpString, 'g')
      const items = value.match(decimalRegexp) || ['0'];
      if (hasDecimalSeparator && !items.some(n => n === decimal)) {
        //we need to add in the decimal point 
        if (items.length <= this.numberFormat.resolvedOptions().minimumFractionDigits) {
          items.unshift(decimal)
        }
        else {
          items.splice(items.length - this.numberFormat.resolvedOptions().minimumFractionDigits, 0, decimal)
        }
      }
      const parsedValue = parseFloat(items.join('').trim())

      return {
        value: parsedValue,
        maskedValue: this.numberFormat.format(parsedValue)
      }
    }
  }


  @boundMethod
  getDecimalSeparator() {
    // a number with a decimal
    let number = 11456456.0222,
      fmt_local: any = this.numberFormat,
      parts_local = fmt_local.formatToParts(number),
      decimal = '';

    parts_local.forEach(function (i: any) {
      switch (i.type) {
        case 'decimal':
          decimal = i.value;
          break;
        default:
          break;
      }
    });

    return decimal;
  }
}

// export default function mask(value?: number | string): MaskedAndRawValues {

//   let nf = new Intl.NumberFormat('en-US', {
//     style: 'currency', currency:
//       'USD'
//   })

//   if (value === null || value === undefined) {
//     return {
//       value: 0,
//       maskedValue: ''
//     };
//   }




//   if (typeof value === 'number') {
//     return {
//       value: value,
//       maskedValue: nf.format(value)
//     }
//   }
//   else {
//     if (value === '') {
//       return {
//         value: 0,
//         maskedValue: ''
//       };
//     }

//     const decimal = findDecimalSeparator(nf)
//     const decimalRegexp = new RegExp(`\d|${decimal}`, 'g')
//     const items = value.match(decimalRegexp) || ['0'];
//     if (!items.some(n => n === decimal)) {
//       //we need to add in the decimal point 
//       if (items.length <= nf.resolvedOptions().minimumFractionDigits) {
//         items.unshift(decimal)
//       }
//       else {
//         items.splice(items.length - nf.resolvedOptions().minimumFractionDigits, 0, decimal)
//       }
//     }
//     const parsedValue = parseFloat(items.join('').trim())

//     return {
//       value: parsedValue,
//       maskedValue: nf.format(parsedValue)
//     }
//   }



  // provide some default values and arg validation.
  // precision = Number(precision)
  // if (precision < 0) { precision = 0; } // precision cannot be negative
  // if (precision > 20) { precision = 20; } // precision cannot be greater than 20

  // if (value === null || value===undefined) {
  //       return {
  //           value: 0,
  //           maskedValue: ''
  //       };
  //  }

  // if (typeof value === 'number'){
  //     value = value.toFixed(precision)
  // }
  // else {
  //     value = String(value); //if the given value is a Number, let's convert into String to manipulate that
  // }

  // if (value.length == 0) {
  //     return {
  //         value: 0,
  //         maskedValue: ''
  //     };
  // }


  // // extract digits. if no digits, fill in a zero.
  // let digits = value.match(/\d/g) || ['0'];

  // let numberIsNegative = false;
  // if (allowNegative) {
  //     let negativeSignCount = (value.match(/-/g) || []).length;
  //     // number will be negative if we have an odd number of "-"
  //     // ideally, we should only ever have 0, 1 or 2 (positive number, making a number negative
  //     // and making a negative number positive, respectively)
  //     numberIsNegative = negativeSignCount % 2 === 1;

  //     // if every digit in the array is '0', then the number should never be negative
  //     let allDigitsAreZero = true;
  //     for (let idx=0; idx < digits.length; idx += 1) {
  //         if(digits[idx] !== '0') {
  //             allDigitsAreZero = false;
  //             break;
  //         }
  //     }
  //     if (allDigitsAreZero) {
  //         numberIsNegative = false;
  //     }
  // }

  // // zero-pad a input
  // while (digits.length <= precision) { digits.unshift('0'); }

  // if (precision > 0) {
  //     // add the decimal separator
  //     digits.splice(digits.length - precision, 0, ".");
  // }

  // // clean up extraneous digits like leading zeros.
  // digits = Number(digits.join('')).toFixed(precision).split('');
  // let raw = Number(digits.join(''));

  // let decimalpos = digits.length - precision - 1;  // -1 needed to position the decimal separator before the digits.
  // if (precision > 0) {
  //     // set the final decimal separator
  //     digits[decimalpos] = decimalSeparator;
  // } else {
  //     // when precision is 0, there is no decimal separator.
  //     decimalpos = digits.length;
  // }

  // // add in any thousand separators
  // for (let x=decimalpos - 3; x > 0; x = x - 3) {
  //     digits.splice(x, 0, thousandSeparator);
  // }

  // // if we have a prefix or suffix, add them in.
  // if (prefix.length > 0) { digits.unshift(prefix); }
  // if (suffix.length > 0) { digits.push(suffix); }

  // // if the number is negative, insert a "-" to
  // // the front of the array and negate the raw value
  // if (allowNegative && numberIsNegative) {
  //     digits.unshift('-');
  //     raw = -raw;
  // }

  // if(raw < minValue){
  //     return mask(minValue, precision, decimalSeparator, thousandSeparator, allowNegative, prefix, suffix, minValue, maxValue)
  // }

  // if (raw > maxValue) {
  //     return mask(maxValue, precision, decimalSeparator, thousandSeparator, allowNegative, prefix, suffix, minValue, maxValue)
  // }

  // return {
  //     value: raw,
  //     maskedValue: digits.join('').trim()
  // };
// }

// function findDecimalSeparator(nf: Intl.NumberFormat) {
//   // a number with a decimal
//   let number = 11456456.0222,
//     fmt_local: any = nf,
//     parts_local = fmt_local.formatToParts(number),
//     decimal = '';

//   parts_local.forEach(function (i: any) {
//     switch (i.type) {
//       case 'decimal':
//         decimal = i.value;
//         break;
//       default:
//         break;
//     }
//   });

//   return decimal;
// }
