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

export interface ClassNameable {
  className?:string
}

interface FieldProps extends ClassNameable{
  field:Field,
  placeholder?:string,
  label?:string
  inputClassNames?:string
}

interface BasicFieldProps extends FieldProps {

}

export const BasicField = observer((props:BasicFieldProps) =>{
    let field = props.field as HoudiniField
    return <LabeledFieldComponent
        inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
        inStickyError={field.hasServerError} stickyError={field.serverError}
        className={props.className} >
        <ReactInput field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames || ''}`}/>
    </LabeledFieldComponent>
})

interface SelectFieldProps extends FieldProps {
  options?:Array<{id:any, name:string}>
}

export const SelectField = observer((props:SelectFieldProps) =>{
  let field = props.field as HoudiniField
  return <LabeledFieldComponent
    inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
    inStickyError={field.hasServerError} stickyError={field.serverError}
    className={props.className} >

    <ReactSelect field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames}`} options={props.options}/>

  </LabeledFieldComponent>
})

interface TextareaFieldProps extends FieldProps {
    rows?:number
}

export const TextareaField = observer((props:TextareaFieldProps) =>{
  let field = props.field as HoudiniField
  return <LabeledFieldComponent
    inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
    inStickyError={field.hasServerError} stickyError={field.serverError}
    className={props.className} >

    <ReactTextarea field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames}`} rows={props.rows}/>

  </LabeledFieldComponent>
})

interface CurrencyFieldProps extends FieldProps {
  currencySymbol?:string, 
  mustBeNegative?:boolean, 
  allowNegative?:boolean
}


export const CurrencyField = observer((props:CurrencyFieldProps) => {
  let field = props.field as HoudiniField
  let currencySymbol = props.mustBeNegative ? "-$" : "$"
  let allowNegative = props.allowNegative || !props.mustBeNegative
  return <LabeledFieldComponent
  inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
  inStickyError={field.hasServerError} stickyError={field.serverError}
  className={props.className} >

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