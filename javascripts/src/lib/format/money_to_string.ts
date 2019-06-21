import { Money } from "../money";
import { MoneyFormatHelper } from "@houdiniproject/react-i18n-currency-input";

export default function moneyToString(locale: string, value: Money|undefined ){
    const currency = (value && value.currency) || 'USD'
    const centValue = (value && value.amountInCents) || 0;
    return MoneyFormatHelper.initializeFromProps(locale, {currency: currency, style:'currency'}).maskFromCents(centValue).maskedValue
}