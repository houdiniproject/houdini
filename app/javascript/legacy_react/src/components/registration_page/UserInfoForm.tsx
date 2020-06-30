// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { injectIntl, WrappedComponentProps} from 'react-intl';
import {Validations} from "../../lib/vjf_rules";
import {Field, FieldDefinition} from "mobx-react-form";
import {TwoColumnFields} from "../common/layout";
import {BasicField} from "../common/fields";
import ProgressableButton from "../common/ProgressableButton";
import {areWeOrAnyParentSubmitting} from "../../lib/houdini_form";

export const FieldDefinitions : Array<FieldDefinition> = [
  {
    name: 'name',
    validators: [Validations.isFilled]
  },
  {
    name: 'email',
    validators: [Validations.isEmail]
  },
  {
    name: 'password',
    type: 'password',
    validators: [Validations.isFilled],
    related: ['userTab.password_confirmation']
  },
  {
    name: 'password_confirmation',
    type: 'password',
    validators: [Validations.shouldBeEqualTo("userTab.password")]
  }
]

export interface UserInfoFormProps
{
  form: Field
  buttonText:string
  buttonTextOnProgress?:string
}



class UserInfoForm extends React.Component<UserInfoFormProps & WrappedComponentProps, {}> {
  render() {
    return <fieldset>
      <TwoColumnFields>
        <BasicField field={this.props.form.$("name")}
            label={
              this.props.intl.formatMessage({id: "registration.wizard.contact.name.label"})}
            placeholder={this.props.intl.formatMessage({id: "registration.wizard.contact.name.placeholder"})}
                    inputClassNames={"input-lg"}/>
        <BasicField field={this.props.form.$('email')}
          label={this.props.intl.formatMessage({id: "registration.wizard.contact.email.label"})}
          placeholder={this.props.intl.formatMessage({id: "registration.wizard.contact.email.placeholder"})}
                    inputClassNames={"input-lg"}
        />
      </TwoColumnFields>

      <BasicField field={this.props.form.$('password')}
                  label={this.props.intl.formatMessage({id:'registration.wizard.contact.password.label'})}
                  inputClassNames={"input-lg"}
                  />
      <BasicField field={this.props.form.$('password_confirmation')}
                  label={this.props.intl.formatMessage({id:'registration.wizard.contact.password_confirmation.label'})}
                  inputClassNames={"input-lg"}
      />


      <ProgressableButton onClick={this.props.form.onSubmit}
                          className="button"
                          disabled={!this.props.form.isValid}
                          buttonText={this.props.intl.formatMessage({id: this.props.buttonText})}
                          inProgress={areWeOrAnyParentSubmitting(this.props.form)}
                          buttonTextOnProgress={this.props.intl.formatMessage({id: this.props.buttonTextOnProgress})}
                          disableOnProgress={true}/>
    </fieldset>;
  }
}

export default injectIntl(observer(UserInfoForm))



