// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react";
import * as _ from 'lodash'
import {Field} from "../../../../types/mobx-react-form";
import LabeledFieldComponent from "./LabeledFieldComponent";
import {injectIntl, InjectedIntl} from 'react-intl';
import {HoudiniField} from "../../lib/houdini_form";


export const BasicField = injectIntl(observer((props:{field:Field, intl?:InjectedIntl, wrapperClassName?:string}) =>{
    let field = props.field as HoudiniField
    return <LabeledFieldComponent
        inputId={props.field.id} labelText={field.label} inError={field.hasError} error={field.error}
        inStickyError={field.hasServerError} stickyError={field.serverError}
        className={props.wrapperClassName} >

        <input {...props.field.bind()} className="form-control"/>
    </LabeledFieldComponent>
}))