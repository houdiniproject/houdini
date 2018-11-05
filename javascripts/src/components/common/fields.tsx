// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react";
import {Field} from "../../../../types/mobx-react-form";
import LabeledFieldComponent from "./LabeledFieldComponent";
import {HoudiniField} from "../../lib/houdini_form";
import ReactInput from "./form/ReactInput";
import ReactSelect from './form/ReactSelect';
import ReactTextarea from "./form/ReactTextarea";
import ReactMaskedInput from "./form/ReactMaskedInput";
import createNumberMask from "../../lib/createNumberMask";
import {CSSProperties} from "react";


function wrapInInputGroupWhenNeeded(input:JSX.Element, prefixInputAddon?:JSX.Element, postfixInputAddon?:JSX.Element) : JSX.Element
{
  if (prefixInputAddon || postfixInputAddon){
    return <div className="input-group">
      {prefixInputAddon}
      {input}
      {postfixInputAddon}
    </div>
  }
  else {
    return input
  }
}

export const BasicField = observer((props:{
  field:Field,
  placeholder?:string,
  label?:string,
  wrapperClassName?:string,
  inputClassNames?:string,
  inputStyle?: CSSProperties,
  wrapperStyle?: CSSProperties,
  prefixInputAddon?: JSX.Element
}) =>{
    let field = props.field as HoudiniField



    return <LabeledFieldComponent
        inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
        inStickyError={field.hasServerError} stickyError={field.serverError}
        className={props.wrapperClassName}  style={props.wrapperStyle}>
      {wrapInInputGroupWhenNeeded(<ReactInput field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames || ''}`}
                    style={props.inputStyle}/>, props.prefixInputAddon)}
    </LabeledFieldComponent>
})

export const SelectField = observer((props:{
  field:Field,
  placeholder?:string,
  label?:string,
  wrapperClassName?:string,
  inputClassNames?:string,
  options?:Array<{id:any, name:string}>,
  inputStyle?: CSSProperties,
  wrapperStyle?: CSSProperties,
}) =>{
  let field = props.field as HoudiniField
  return <LabeledFieldComponent
    inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
    inStickyError={field.hasServerError} stickyError={field.serverError}
    className={props.wrapperClassName} style={props.wrapperStyle}>

    <ReactSelect field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames}`} options={props.options} style={props.inputStyle}/>

  </LabeledFieldComponent>
})

export const TextareaField = observer((props:{field:Field, placeholder?:string, label?:string, wrapperClassName?:string, inputClassNames?:string, rows?:number}) =>{
  let field = props.field as HoudiniField
  return <LabeledFieldComponent
    inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
    inStickyError={field.hasServerError} stickyError={field.serverError}
    className={props.wrapperClassName} >

    <ReactTextarea field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames}`} rows={props.rows}/>

  </LabeledFieldComponent>
})

export const CurrencyField = observer((props:{
  field:Field,
  placeholder?:string,
  label?:string,
  currencySymbol?:string,
  wrapperClassName?:string,
  inputClassNames?:string,
  mustBeNegative?:boolean,
  allowNegative?:boolean,
  inputStyle?: CSSProperties,
  wrapperStyle?: CSSProperties,
}) => {
  let field = props.field as HoudiniField
  let currencySymbol = props.mustBeNegative ? "-$" : "$"
  let allowNegative = props.allowNegative || !props.mustBeNegative
  return <LabeledFieldComponent
  inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
  inStickyError={field.hasServerError} stickyError={field.serverError}
  className={props.wrapperClassName} style={props.wrapperStyle} >

      <ReactMaskedInput field={field} label={props.label} placeholder={props.placeholder}
                        className={`form-control ${props.inputClassNames}`} guide={true}
                        mask={createNumberMask({allowDecimal:true,
                          requireDecimal:true,
                          prefix:currencySymbol,
                          allowNegative:allowNegative,
                          fixedDecimalScale:true
                        })}
                        showMask={true} placeholderChar={'0'} style={props.inputStyle}
      />

  </LabeledFieldComponent>


});