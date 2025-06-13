// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject} from 'mobx-react';
import {InjectedIntlProps, injectIntl, FormattedMessage} from 'react-intl';
import {Field, FieldDefinition, Form, initializationDefinition} from "../../../../types/mobx-react-form";
import {Validations} from "../../lib/vjf_rules";
import {WebLoginModel, WebUserSignInOut} from "../../lib/api/sign_in";

import {HoudiniForm, StaticFormToErrorAndBackConverter} from "../../lib/houdini_form";
import {observable, action, runInAction} from 'mobx'
import {ApiManager} from "../../lib/api_manager";
import {BasicField} from "../common/fields";
import ProgressableButton from "../common/ProgressableButton";
import { ErrorDivDetails } from './ErrorDivDetails';

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
  },
  {
    name: 'otp_attempt',
    type: 'text',
    validators: []
  }
]

export class SessionPageForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<WebLoginModel>

  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
    this.converter = new StaticFormToErrorAndBackConverter<WebLoginModel>(this.inputToForm)
  }

  signinApi: WebUserSignInOut

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
    'password': 'password',
    'otp_attempt': 'otp_attempt'
  }
}

class InnerSessionLoginForm extends React.Component<SessionLoginFormProps & InjectedIntlProps, {}> {
  constructor(props: SessionLoginFormProps & InjectedIntlProps) {
    super(props)
    this.createForm();
  }

  @action.bound
  createForm() {
    this.form = new SessionPageForm({fields: FieldDefinitions})
  }

  @action.bound
  handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()

    this.form.onSubmit(e, {
      onSuccess: async (form: SessionPageForm) => {
        const input = form.converter.convertFormToObject(form)

        try {
          const response = await form.signinApi.postLogin(input)

          if (response.status === 'Success') {
            window.location.reload()
          } else if (response.status === 'otp_required') {
            if (!this.otpSent) {
              await this.sendOtp()
            }
            runInAction(() => {
              this.showOtpField = true
            })
          }
        } catch (e) {
          if (e.error) {
            form.invalidateFromServer(e.error)
          } else {
            form.invalidateFromServer(e)
          }
        }
      }
    })
  }

  @action.bound
  sendOtp = async () => {
    this.otpSent = false
    const email = this.form.$('email').value
    const password = this.form.$('password').value

    try {
      const response = await fetch('/users/send_otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email, password: password }),
      })

      const data = await response.json()

      if (data.status === 'success') {
        runInAction(() => {
          this.otpSent = true
          this.form.clearServerErrors()
        })
      } else {
        this.form.invalidateFromServer(data || 'Failed to send OTP')
      }
    } catch (error) {
      this.form.invalidateFromServer('An error occurred')
    }
  }

  componentWillMount(){
    runInAction(() => {
      this.form.signinApi = this.props.ApiManager.get(WebUserSignInOut)
    })
  }

  @observable form: SessionPageForm
  @observable showOtpField = false
  @observable otpSent = false


  render() {

    const errorDiv = <ErrorDivDetails isValid={this.form.isValid} hasServerError={this.form.hasServerError} serverError={this.form.serverError}/>

    return <form onSubmit={this.handleSubmit}>
      <BasicField field={this.form.$('email')}
        label={this.props.intl.formatMessage({id: 'login.email'})} inputClassNames={"input-lg"}/>
      <BasicField field={this.form.$('password')}
                  label={this.props.intl.formatMessage({id: 'login.password'})} inputClassNames={"input-lg"}/>
      {this.showOtpField && (
        <>
          {this.otpSent && <p>{this.props.intl.formatMessage({id: 'login.otp_help'})}</p>}
          {!this.otpSent && <p>{this.props.intl.formatMessage({id: 'login.otp_sending'})}</p>}
          <div>
            <BasicField
              field={this.form.$("otp_attempt")}
              label={this.props.intl.formatMessage({ id: 'login.otp_label' })}
              inputClassNames={"input-lg"}
              placeholder={this.props.intl.formatMessage({ id: 'login.otp_placeholder' })}
              inputMode="numeric"
              pattern="[0-9]*"
            />
          </div>
        </>
      )}
      {errorDiv}
      <div className={'form-group'}>
        <ProgressableButton onClick={this.handleSubmit} className="button" disabled={!this.form.isValid || this.form.submitting} inProgress={this.form.submitting}
                          buttonText={this.props.intl.formatMessage({id: this.props.buttonText})}
                          buttonTextOnProgress={this.props.intl.formatMessage({id: this.props.buttonTextOnProgress})}></ProgressableButton>
      </div>
      <div className={'row'}>
        {this.showOtpField && (
          <div className={'col-xs-12 col-sm-6 login-bottom-link'}>
            <a
              href="#"
              onClick={(e) => {
                e.preventDefault()
                this.sendOtp()
              }}
            >
              <FormattedMessage id={"login.otp_resend"}/>
            </a>
          </div>
        )}
        {!this.showOtpField && (
          <div className={'col-xs-12 col-sm-6 login-bottom-link'}><a href={'/users/password/new'}><FormattedMessage id={"login.forgot_password"}/></a></div>
        )}
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
