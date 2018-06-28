// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {Field, FieldDefinition} from "../../../../types/mobx-react-form";
import {BasicField} from "../common/fields";
import {ThreeColumnFields, TwoColumnFields} from "../common/layout";
import {Validations} from "../../lib/vjf_rules";
import ProgressableButton from "../common/ProgressableButton";

export interface NonprofitInfoFormProps
{
  form:Field
  buttonText:string
}

export const FieldDefinitions : Array<FieldDefinition> = [
  {
    name: 'organization_name',
    label: 'registration.wizard.nonprofit.name',
    type: 'text',
    validators: [Validations.isFilled]
  },
  {
    name: 'website',
    label: 'registration.wizard.nonprofit.website',
    validators: [Validations.optional(Validations.isUrl)]
  },
  {
    name: 'org_email',
    label: 'registration.wizard.nonprofit.email',
    validators: [Validations.optional(Validations.isEmail)]
  },
  {
    name: 'org_phone',
    label: 'registration.wizard.nonprofit.phone',
    type: "tel"
  },
  {
    name: 'city',
    label: 'registration.wizard.nonprofit.city',
    validators: [Validations.isFilled]
  },
  {
    name: 'state',
    label: 'registration.wizard.nonprofit.state',
    type: 'text',
    validators: [Validations.isFilled]

  },
  {
    name: 'zip',
    label: 'registration.wizard.nonprofit.zip',
    validators: [Validations.isFilled]
  }
]

class NonprofitInfoForm extends React.Component<NonprofitInfoFormProps & InjectedIntlProps, {}> {


  render() {
     return <fieldset >
       <BasicField field={this.props.form.$("organization_name")}/>
       <BasicField field={this.props.form.$('website')}/>
       <TwoColumnFields>
         <BasicField field={this.props.form.$('org_email')}/>
         <BasicField field={this.props.form.$('org_phone')}/>
       </TwoColumnFields>

       <ThreeColumnFields>
         <BasicField field={this.props.form.$('city')}/>
         <BasicField field={this.props.form.$('state')}/>
         <BasicField field={this.props.form.$('zip')}/>
       </ThreeColumnFields>
       <ProgressableButton onClick={this.props.form.onSubmit} className="button" disabled={!this.props.form.isValid} title={this.props.intl.formatMessage({id: this.props.buttonText})} inProgress={this.props.form.submitting || this.props.form.container().submitting} disableOnProgress={true}/>
     </fieldset>
  }
}

export default injectIntl(observer(NonprofitInfoForm))



