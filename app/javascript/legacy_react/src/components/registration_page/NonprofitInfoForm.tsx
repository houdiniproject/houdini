// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {Field, FieldDefinition} from "../../../../../../types/mobx-react-form";
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
    validators: [Validations.isFilled]
  },
  {
    name: 'website',
    validators: [Validations.optional(Validations.isUrl)]
  },
  {
    name: 'org_email',
    validators: [Validations.optional(Validations.isEmail)]
  },
  {
    name: 'org_phone',
    type: "tel"
  },
  {
    name: 'city',
    validators: [Validations.isFilled]
  },
  {
    name: 'state',
    validators: [Validations.isFilled]

  },
  {
    name: 'zip',
    validators: [Validations.isFilled]
  }
]

class NonprofitInfoForm extends React.Component<NonprofitInfoFormProps & InjectedIntlProps, {}> {


  render() {
     return <fieldset >

       <BasicField field={this.props.form.$("organization_name")}
                   label={this.props.intl.formatMessage({id:'registration.wizard.nonprofit.name.label' })}
                   placeholder={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.name.placeholder'})}
                   inputClassNames={"input-lg"}
       />

       <BasicField field={this.props.form.$('website')}
                   label={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.website.label'})}
                   placeholder={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.website.placeholder'})}
                   inputClassNames={"input-lg"}/>

       <TwoColumnFields>
         <BasicField field={this.props.form.$('org_email')}
                     label={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.email.label'})}
                     placeholder={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.email.placeholder'})}
                     inputClassNames={"input-lg"}/>
         <BasicField field={this.props.form.$('org_phone')}
                     label={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.phone.label'})}
                     placeholder={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.phone.placeholder'})}
                     inputClassNames={"input-lg"}/>
       </TwoColumnFields>

       <ThreeColumnFields>
         <BasicField field={this.props.form.$('city')}
                     label={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.city.label'})}
                     placeholder={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.city.placeholder'})}
                     inputClassNames={"input-lg"}/>
         <BasicField field={this.props.form.$('state')}
                     label={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.state.label'})}
                     placeholder={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.state.placeholder'})}
                     inputClassNames={"input-lg"}/>
         <BasicField field={this.props.form.$('zip')}
                     label={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.zip.label' })}
                     placeholder={this.props.intl.formatMessage({id: 'registration.wizard.nonprofit.zip.placeholder'})}
                     inputClassNames={"input-lg"}/>
       </ThreeColumnFields>

       <ProgressableButton onClick={this.props.form.onSubmit} className="button" disabled={!this.props.form.isValid} buttonText={this.props.intl.formatMessage({id: this.props.buttonText})}
                           inProgress={this.props.form.submitting || this.props.form.container().submitting} disableOnProgress={true}/>
     </fieldset>
  }
}

export default injectIntl(observer(NonprofitInfoForm))



