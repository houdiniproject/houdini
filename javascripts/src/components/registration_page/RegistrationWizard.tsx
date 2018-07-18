// License: LGPL-3.0-or-later
import * as React from 'react';

import {observer, inject} from 'mobx-react'
import NonprofitInfoPanel from './NonprofitInfoPanel'
import {action,  observable, computed, runInAction} from 'mobx';
import {Wizard} from '../common/wizard/Wizard'

import {Form} from 'mobx-react-form';
import {FormattedMessage, injectIntl, InjectedIntlProps} from 'react-intl';
import {WizardState} from "../common/wizard/wizard_state";
import UserInfoPanel, * as UserInfo from "./UserInfoPanel";
import {
  Nonprofit,
  NonprofitApi,
  PostNonprofit,
  ValidationErrorsException
} from "../../../api";

import {initializationDefinition} from "../../../../types/mobx-react-form";
import {ApiManager} from "../../lib/api_manager";
import {HoudiniForm, StaticFormToErrorAndBackConverter} from "../../lib/houdini_form";
import {WebUserSignInOut} from "../../lib/api/sign_in";
import * as NonprofitInfoForm from "./NonprofitInfoForm";
import * as UserInfoForm from "./UserInfoForm";

export interface RegistrationWizardProps {
  ApiManager?: ApiManager
}
const setTourCookies = (nonprofit:Nonprofit) => {
  document.cookie = `tour_dashboard=${nonprofit.id};path=/`
  document.cookie = `tour_campaign=${nonprofit.id};path=/`
  document.cookie = `tour_event=${nonprofit.id};path=/`
  document.cookie = `tour_profile=${nonprofit.id};path=/`
  document.cookie = `tour_transactions=${nonprofit.id};path=/`
  document.cookie = `tour_supporters=${nonprofit.id};path=/`
  document.cookie = `tour_subscribers=${nonprofit.id};path=/`
}

export class RegistrationPageForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<PostNonprofit>

  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
    this.converter = new StaticFormToErrorAndBackConverter<PostNonprofit>(this.inputToForm)
  }

  nonprofitApi: NonprofitApi
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
    'nonprofit[name]': 'nonprofitTab.organization_name',
    'nonprofit[url]': 'nonprofitTab.website',
    'nonprofit[email]': 'nonprofitTab.org_email',
    'nonprofit[phone]': 'nonprofitTab.org_phone',
    'nonprofit[city]': 'nonprofitTab.city',
    'nonprofit[state_code]': 'nonprofitTab.state',
    'nonprofit[zip_code]': 'nonprofitTab.zip',
    'user[name]': 'userTab.name',
    'user[email]': 'userTab.email',
    'user[password]': 'userTab.password',
    'user[password_confirmation]': 'userTab.password_confirmation'
  }

  hooks() {
    return {
      onSuccess: async (f: Form) => {
        let input = this.converter.convertFormToObject(f)


        try {
          let r = await this.nonprofitApi.postNonprofit(input)
          setTourCookies(r)
          await this.signinApi.postLogin({email: input.user.email, password: input.user.password})
          window.location.href = `/nonprofits/${r.id}/dashboard`

        }
        catch (e) {
          console.log(e)
          if (e instanceof ValidationErrorsException) {
            this.converter.convertErrorToForm(e, f)
          }

          this.invalidateFromServer(e['error'])
          //set error to the form
        }
      }
    }
  }

}

class RegistrationWizardState extends WizardState {
  @action.bound
  createForm(i: any): Form {
    return new RegistrationPageForm(i)
  }


}

export class InnerRegistrationWizard extends React.Component<RegistrationWizardProps & InjectedIntlProps, {}> {

  constructor(props: RegistrationWizardProps & InjectedIntlProps) {
    super(props)

    this.setRegistrationWizardState()
    this.createForm()
  }


  @observable registrationWizardState: RegistrationWizardState

  @computed
  get form(): RegistrationPageForm {
    return (this.registrationWizardState && this.registrationWizardState.form)as RegistrationPageForm
  }


  @action.bound
  setRegistrationWizardState() {
    this.registrationWizardState = new RegistrationWizardState()
  }


  @action.bound
  createForm() {
    this.registrationWizardState.addTab("nonprofitTab", 'registration.wizard.tabs.nonprofit', {
      fields:
        NonprofitInfoForm.FieldDefinitions,
      hooks: {
        onError: (f: any) => {
          console.log(f)
        },
        onSuccess: (f: any) => {
          console.log(f)
        }

      }
    })

    this.registrationWizardState.addTab("userTab", 'registration.wizard.tabs.contact', {
      fields:
        UserInfoForm.FieldDefinitions,
      hooks: {
        onError: (f: any) => {

        },
        onSuccess: (f: any) => {

        }

      }
    })

    this.registrationWizardState.initialize()
  }

  componentWillMount()
  {
    runInAction(() => {
      this.form.nonprofitApi = this.props.ApiManager.get(NonprofitApi)
      this.form.signinApi = this.props.ApiManager.get(WebUserSignInOut)
    })
  }


  render() {

    return <Wizard wizardState={this.registrationWizardState} disableTabs={this.form.submitting}>
      <NonprofitInfoPanel tab={this.registrationWizardState.tabsByName['nonprofitTab']}
                           buttonText="registration.wizard.next"/>

      <UserInfoPanel tab={this.registrationWizardState.tabsByName['userTab']}
                     buttonText="registration.wizard.save_and_finish" buttonTextOnProgress="registration.wizard.saving"/>
    </Wizard>
  }
}

export default injectIntl(
  inject('ApiManager')
    (observer( InnerRegistrationWizard)
  )
)