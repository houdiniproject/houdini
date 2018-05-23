// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {Validations} from "../../lib/vjf_rules";
import {Field, FieldDefinition} from "mobx-react-form";
import {TwoColumnFields} from "../common/layout";
import {BasicField} from "../common/fields";

export const FieldDefinitions : Array<FieldDefinition> = [
  {
    name: 'name',
    label: 'registration.wizard.contact.name',
    validators: [Validations.isFilled]
  },
  {
    name: 'email',
    label: 'registration.wizard.contact.email',
    validators: [Validations.isEmail]
  },
  {
    name: 'password',
    label: 'registration.wizard.contact.password',
    type: 'password',
    validators: [Validations.isFilled],
    related: ['userTab.password_confirmation']
  },
  {
    name: 'password_confirmation',
    label: 'registration.wizard.contact.password_confirmation',
    type: 'password',
    validators: [Validations.shouldBeEqualTo("userTab.password")]
  }
]

export interface UserInfoFormProps
{
  form: Field
  buttonText:string
}



class UserInfoForm extends React.Component<UserInfoFormProps & InjectedIntlProps, {}> {
  render() {
    return <fieldset>
      <TwoColumnFields>
        <BasicField field={this.props.form.$("name")}/>
        <BasicField field={this.props.form.$('email')}/>
      </TwoColumnFields>

      <BasicField field={this.props.form.$('password')}/>
      <BasicField field={this.props.form.$('password_confirmation')}/>


      <button onClick={this.props.form.onSubmit} className="button" disabled={!this.props.form.isValid || this.props.form.submitting}>
        {this.props.intl.formatMessage({id: this.props.buttonText})}
      </button>
    </fieldset>;
  }
}

export default injectIntl(observer(UserInfoForm))



