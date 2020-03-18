// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { Validations } from "../../lib/vjf_rules";
import { Field, FieldDefinition } from "mobx-react-form";
import { TwoColumnFields } from "../common/layout";
import { BasicField } from "../common/fields";
import ProgressableButton from "../common/ProgressableButton";
import { areWeOrAnyParentSubmitting } from "../../lib/houdini_form";

export const FieldDefinitions: Array<FieldDefinition> = [
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

export interface UserInfoFormProps {
  form: Field
  buttonText: string
  buttonTextOnProgress?: string
}



class UserInfoForm extends React.Component<UserInfoFormProps & InjectedIntlProps, {}> {
  render() {
    return <fieldset>
      <TwoColumnFields>
        <BasicField field={this.props.form.$("name")}
          label={
            this.props.intl.formatMessage({ id: "registration.wizard.contact.name.label" })}
          placeholder={this.props.intl.formatMessage({ id: "registration.wizard.contact.name.placeholder" })}
          inputClassNames={"input-lg"} />
        <BasicField field={this.props.form.$('email')}
          label={this.props.intl.formatMessage({ id: "registration.wizard.contact.email.label" })}
          placeholder={this.props.intl.formatMessage({ id: "registration.wizard.contact.email.placeholder" })}
          inputClassNames={"input-lg"}
        />
      </TwoColumnFields>

      <BasicField field={this.props.form.$('password')}
        label={this.props.intl.formatMessage({ id: 'registration.wizard.contact.password.label' })}
        inputClassNames={"input-lg"}
      />
      <BasicField field={this.props.form.$('password_confirmation')}
        label={this.props.intl.formatMessage({ id: 'registration.wizard.contact.password_confirmation.label' })}
        inputClassNames={"input-lg"}
      />

      <div className={"pastelBox--grey u-padding--20 u-marginBottom--30"} style={{ display: 'inline-flex', color: '#494949' }}>

        <div style={{ alignSelf: 'center' }}>
          <i className='fa fa-info-circle' style={{ fontSize: '36px' }} ></i>
        </div>
        
        <div className="u-marginLeft--20">After saving you'll be asked to complete Stripe verification for your organization. If you don't complete the verification, you will <strong>not</strong> be able to accept payments on CommitChange.</div>
      </div>


      <ProgressableButton onClick={this.props.form.onSubmit}
        className="button"
        disabled={!this.props.form.isValid}
        buttonText={this.props.buttonText}
        inProgress={areWeOrAnyParentSubmitting(this.props.form)}
        buttonTextOnProgress={this.props.buttonTextOnProgress}
        disableOnProgress={true} />
    </fieldset>;
  }
}

export default injectIntl(observer(UserInfoForm))



