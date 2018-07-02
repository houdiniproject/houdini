// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react";
import {Field} from "../../../../types/mobx-react-form";
import LabeledFieldComponent from "./LabeledFieldComponent";
import {InjectedIntl, injectIntl} from 'react-intl';

import {HoudiniField} from "../../lib/houdini_form";
import Autocomplete  = require('react-autocomplete');


export const BasicField = injectIntl(observer((props:{field:Field, intl?:InjectedIntl, wrapperClassName?:string}) =>{
    let field = props.field as HoudiniField
    return <LabeledFieldComponent
        inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
        inStickyError={field.hasServerError} stickyError={field.serverError}
        className={props.wrapperClassName} >

        <input {...props.field.bind()} className="form-control"/>
    </LabeledFieldComponent>
}))
export function matchStateToTerm(state:{name:string}, value:string) {
  return (
    state.name.toLowerCase().indexOf(value.toLowerCase()) !== -1
  )
}
export const AutocompleteField = injectIntl(observer((props:{field:Field, intl?:InjectedIntl, wrapperClassName?:string, items: any[]}) =>{

  return <LabeledFieldComponent
    inputId={props.field.id} labelText={props.field.label} inError={props.field.hasError} error={props.field.error} className={props.wrapperClassName} >

    <Autocomplete items={props.items} getItemValue={(item) => item.name}
                  shouldItemRender={matchStateToTerm}
                  renderItem={(item, isHighlighted:boolean) => (
                    <div
                      className={`item ${isHighlighted ? 'item-highlighted' : ''}`}
                      key={item.name}
                    >{item.name}</div>)}
        value={props.field.value}
        inputProps={{className:"form-control", type: 'text'}}
        onSelect={(value) => props.field.set(value)} menuStyle={{
      borderRadius: '3px',
      boxShadow: '0 2px 12px rgba(0, 0, 0, 0.1)',
      background: 'rgba(255, 255, 255, 0.9)',
      padding: '2px',
      fontSize: '90%',
      position: 'fixed',
      overflow: 'auto',
      maxHeight: '50%', // TODO: don't cheat, let it flow to the bottom
      marginTop: '-12px'
    }}
    wrapperStyle={{}} {...props.field.bind()}/>
  </LabeledFieldComponent>
}))