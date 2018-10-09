// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react";
import {Field} from "../../../../types/mobx-react-form";
import LabeledFieldComponent from "./LabeledFieldComponent";
import {injectIntl, InjectedIntl} from 'react-intl';
import {HoudiniField} from "../../lib/houdini_form";
import ReactInput from "./form/ReactInput";


export const BasicField = observer((props:{field:Field, placeholder?:string, label?:string, wrapperClassName?:string, inputClassNames?:string}) =>{
    let field = props.field as HoudiniField
    return <LabeledFieldComponent
        inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
        inStickyError={field.hasServerError} stickyError={field.serverError}
        className={props.wrapperClassName} >

        <ReactInput field={field} label={props.label} placeholder={props.placeholder} className={`form-control ${props.inputClassNames || ''}`}/>
    </LabeledFieldComponent>
})