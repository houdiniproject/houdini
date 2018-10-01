// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react";
import {Field} from "../../../../types/mobx-react-form";
import LabeledFieldComponent from "./LabeledFieldComponent";
import {injectIntl, InjectedIntl} from 'react-intl';
import {HoudiniField} from "../../lib/houdini_form";
import ReactInput from "./form/ReactInput";
import ReactSelect from './form/ReactSelect';
import ReactTextarea from "./form/ReactTextarea";


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

export const CurrencyField = observer((props:{field:Field,placeholder?:string, label?:string, currencySymbol?:string, wrapperClassName?:string, inputClassNames?:string}) => {
  let field = props.field as HoudiniField
  let currencySymbolId = props.field.id + "_____currency_symbol"
  return <LabeledFieldComponent
  inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
  inStickyError={field.hasServerError} stickyError={field.serverError}
  className={props.wrapperClassName} >
    <div className="input-group">
      <span className="input-group-addon" id={currencySymbolId}>{props.currencySymbol}</span>
      <ReactInput field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames}`} aria-describedby={currencySymbolId}/>
    </div>
  </LabeledFieldComponent>


});