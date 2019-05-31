// License: LGPL-3.0-or-later
declare module "react-currency-input"

export interface CurrencyInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    // initial currency value
    // default: 0
    value?:number,
    
    //Callback function to handle value changes
    onChangeEvent?:(event:React.ChangeEvent<any>, maskedValue:string, value:number) => 	void,

    //Number of digits after the decimal separator
    //default 2
    precision?:number,

    //Decimal separator
    //default '.'
    decimalSeparator?:string, 	
    
    //The thousand separator,
    // default:	',' 
    thousandSeparator?:string 	
    
    // the inputType
    // Input field tag type. You may want to use number or tel*
    // dfeault: text
    inputType?: 	string 	
    
    // allow negative numbers in input
    //Allows negative numbers in the input
    // default: false
    allowNegative?:boolean

    // If no value is given, defines if it starts as null (true) or '' (false)
    // default: false
    allowEmpty?:boolean
    
    // 	Selects all text on focus or does not
    // default: false
    selectAllOnFocus?: boolean
    
    // Currency prefix
    // default: ''
    prefix?: string

    //Currency suffix
    // default: ''
    suffix?:string

    //default: false
    autoFocus?:boolean
}

export default class CurrencyInput extends React.Component<ReactCurrencyInputProps, {}>
{
    getMaskedValue() : string
}