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


export const BasicField = observer((props:{field:Field, placeholder?:string, label?:string, wrapperClassName?:string, inputClassNames?:string}) =>{
    let field = props.field as HoudiniField
    return <LabeledFieldComponent
        inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
        inStickyError={field.hasServerError} stickyError={field.serverError}
        className={props.wrapperClassName} >
        <ReactInput field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames || ''}`}/>
    </LabeledFieldComponent>
})

export const SelectField = observer((props:{field:Field, placeholder?:string, label?:string, wrapperClassName?:string, inputClassNames?:string,  options?:Array<{id:any, name:string}>}) =>{
  let field = props.field as HoudiniField
  return <LabeledFieldComponent
    inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
    inStickyError={field.hasServerError} stickyError={field.serverError}
    className={props.wrapperClassName} >

    <ReactSelect field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames}`} options={props.options}/>

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

export const CurrencyField = observer((props:{field:Field,placeholder?:string, label?:string, currencySymbol?:string, wrapperClassName?:string, inputClassNames?:string, mustBeNegative?:boolean, allowNegative?:boolean}) => {
  let field = props.field as HoudiniField
  let currencySymbol = props.mustBeNegative ? "-$" : "$"
  let allowNegative = props.allowNegative || !props.mustBeNegative
  return <LabeledFieldComponent
  inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
  inStickyError={field.hasServerError} stickyError={field.serverError}
  className={props.wrapperClassName} >

      <ReactMaskedInput field={field} label={props.label} placeholder={props.placeholder}
                        className={`form-control ${props.inputClassNames}`} guide={true}
                        mask={createNumberMask({allowDecimal:true,
                          requireDecimal:true,
                          prefix:currencySymbol,
                          allowNegative:allowNegative,
                          fixedDecimalScale:true
                        })}
                        showMask={true} placeholderChar={'0'}
      />

  </LabeledFieldComponent>


});