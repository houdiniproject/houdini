
// License: LGPL-3.0-or-later
import { Money } from '../money';
import { boundMethod } from 'autobind-decorator';
import YupLocaleValues from './types';
import * as yup from 'yup'
import { MoneyFormatHelper } from '@houdiniproject/react-i18n-currency-input';
import * as locales from 'yup/lib/locale'

export function isAbsent(i: any) {
  return i == null
}
export function createStringValueForCondition(schema:MoneySchema, value:Money, conditionAmount:Money):string {
  const locale = schema.locale
  const money = MoneyFormatHelper.initializeFromProps(locale, { currency: conditionAmount.currency }).maskFromCents(conditionAmount.amountInCents)
  return money.maskedValue
}

function coerceConditionAmount(value:Money, conditionAmount:number|Money|any)
{
  if (conditionAmount instanceof Money)
    return conditionAmount
  else {
    return Money.fromCents(conditionAmount, value.currency)
  }
}

function compareMoney(comparer:() => boolean):boolean {
  try {
    return comparer()
  }
  catch(e){
    return false;
  }
}

export class MoneySchema extends yup.mixed {
  constructor(readonly locale: string = 'en-US', readonly localeValues: YupLocaleValues = locales) {
    super();
  }
  /**
   *
   * @param  {number} min the amount in cents
   * @param  {string} [message=this.localeValues.number.min]
   * @return MoneySchema
   * @memberof MoneySchema
   */
  @boundMethod
  min(min: number|Money, message: string = this.localeValues.number.min): this {
    return this.test({
      message,
      name: 'min',
      test(this: yup.TestContext, value: Money) {
        if(isAbsent(value))
          return true
        let resolved = coerceConditionAmount(value, this.resolve(min))
        const valid = compareMoney(() => value.greaterThanOrEqual(resolved) );
        let error: yup.ValidationError;
        if (!valid) {
          const ourStringValue = createStringValueForCondition(this.schema as MoneySchema, value, resolved);
          const newMessage = message
            .replace('${min}', ourStringValue);
          error = this.createError({ message: newMessage });
        }
        return valid || error;
      },
    });
  }
  @boundMethod
  max(max: number|Money, message = this.localeValues.number.max) {
    return this.test({
      message,
      name: 'max',
      test(this: yup.TestContext, value: Money) {
        if(isAbsent(value))
          return true
        let resolved = coerceConditionAmount(value, this.resolve(max))
        const valid =  compareMoney(() => value.lessThanOrEqual(resolved));
        let error: yup.ValidationError;
        if (!valid) {
          const ourStringValue = createStringValueForCondition(this.schema as MoneySchema, value, resolved);
          const newMessage = message
            .replace('${max}', ourStringValue);
          error = this.createError({ message: newMessage });
        }
        return valid || error;
      },
    });
  }

  @boundMethod
  lessThan(less: number|Money, message = this.localeValues.number.lessThan) {
    return this.test({
      message,
      name: 'max',
      test(this: yup.TestContext, value: Money) {
        if(isAbsent(value))
          return true
        let resolved = coerceConditionAmount(value, this.resolve(less))
        const valid = compareMoney(() => value.lessThan(resolved))
        let error: yup.ValidationError;
        if (!valid) {
          const ourStringValue = createStringValueForCondition(this.schema as MoneySchema, value, resolved);
          const newMessage = message
            .replace('${less}', ourStringValue);
          error = this.createError({ message: newMessage });
        }
        return valid || error;
      },
    });
  }

  @boundMethod
  moreThan(more: number|Money, message = locales.number.moreThan) {
    return this.test({
      message,
      name: 'min',
      test(this: yup.TestContext, value: Money) {
        if(isAbsent(value))
          return true
        let resolved = coerceConditionAmount(value, this.resolve(more))
        const valid = compareMoney(() => value.greaterThan(resolved));
        let error: yup.ValidationError;
        if (!valid) {
          const ourStringValue = createStringValueForCondition(this.schema as MoneySchema, value, resolved);
          const newMessage = message
            .replace('${more}', ourStringValue);
          error = this.createError({ message: newMessage });
        }
        return valid || error;
      },
    });
  }

  @boundMethod
  positive(msg = locales.number.positive) {
    return this.moreThan(0, msg);
  }
  
  @boundMethod
  negative(msg = locales.number.negative) {
    return this.lessThan(0, msg);
  }
}