// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject} from 'mobx-react';
import { injectIntl, FormattedMessage, WrappedComponentProps} from 'react-intl';
import {Field, FieldDefinition, Form, initializationDefinition} from "../../../../../../types/mobx-react-form";
import {Validations} from "../../lib/vjf_rules";
import WebUserSignInOut, {WebLoginModel} from "../../lib/api/sign_in";

import {HoudiniForm, StaticFormToErrorAndBackConverter} from "../../lib/houdini_form";
import {observable, action, runInAction} from 'mobx'
import {ApiManager} from "../../lib/api_manager";
import {BasicField} from "../common/fields";
import ProgressableButton from "../common/ProgressableButton";

export interface SessionLoginFormProps
{

  buttonText:string
  buttonTextOnProgress:string
  ApiManager?: ApiManager
}

export const FieldDefinitions : Array<FieldDefinition> = [
  {
    name: 'email',
    type: 'text',
    validators: [Validations.isFilled]
  },
  {
    name: 'password',
    type: 'password',
    validators: [Validations.isFilled]
  }
]

export class SessionPageForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<WebLoginModel>

  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
    this.converter = new StaticFormToErrorAndBackConverter<WebLoginModel>(this.inputToForm)
  }

  signinApi: typeof WebUserSignInOut

  options() {
    return {
      validateOnInit: true,
      validateOnChange: true,
      retrieveOnlyDirtyValues: true,
      retrieveOnlyEnabledFields: true
    }
  }

  inputToForm = {
    'email': 'email',
    'password': 'password'
  }

  hooks() {
    return {
      onSuccess: async (f:SessionPageForm) => {
        let input = this.converter.convertFormToObject(f)

        try{
          let r = await this.signinApi.postSignIn(input)
          window.location.reload()
        }
        catch(e){
          if (e.error) {
            f.invalidateFromServer(e.error)
          }
          else {
            f.invalidateFromServer(e)
          }
        }
      }
    }
  }
}


class InnerSessionLoginForm extends React.Component<SessionLoginFormProps  & WrappedComponentProps, {}> {
  constructor(props: SessionLoginFormProps & WrappedComponentProps) {
    super(props)
    this.createForm();
  }

  @action.bound
  createForm() {
    this.form = new SessionPageForm({fields: FieldDefinitions})
  }

  componentWillMount(){
    runInAction(() => {
      this.form.signinApi = WebUserSignInOut
    })
  }

  @observable form: SessionPageForm

  render() {

    let errorDiv = !this.form.isValid || this.form.hasServerError ? <div className="form-group has-error"><div className="help-block" role="alert">{this.form.serverError}</div></div> : ''

    return <form onSubmit={this.form.onSubmit}>
      <BasicField field={this.form.$('email')}
        label={this.props.intl.formatMessage({id: 'login.email'})} inputClassNames={"input-lg"}/>
      <BasicField field={this.form.$('password')}
                  label={this.props.intl.formatMessage({id: 'login.password'})} inputClassNames={"input-lg"}/>
      {errorDiv}
      <div className={'form-group'}>
        <ProgressableButton onClick={this.form.onSubmit} className="button" disabled={!this.form.isValid || this.form.submitting} inProgress={this.form.submitting}
                          buttonText={this.props.intl.formatMessage({id: this.props.buttonText})}
                          buttonTextOnProgress={this.props.intl.formatMessage({id: this.props.buttonTextOnProgress})}></ProgressableButton>
      </div>
      <div className={'row'}>
        <div className={'col-xs-12 col-sm-6 login-bottom-link'}><a href={'/users/password/new'}><FormattedMessage id={"login.forgot_password"}/></a></div>
        <div className={'col-xs-12 col-sm-6 login-bottom-link'}><a href={'/onboard'}><div className={'visible-xs-block'}><FormattedMessage id={"login.get_started"}/></div><div className={"hidden-xs"} style={{"textAlign":"right"}}><FormattedMessage id={"login.get_started"}/></div></a></div>
      </div>
    </form>;
  }
}

export default injectIntl(
  inject('ApiManager')
  (observer( InnerSessionLoginForm)
  )
)



