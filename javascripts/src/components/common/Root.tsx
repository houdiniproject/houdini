// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer, Provider} from 'mobx-react';
import {addLocaleData, IntlProvider} from 'react-intl';
import {convert} from 'dotize'
import {ApiManager} from "../../lib/api_manager";
import {APIS} from "../../../api";
import {CSRFInterceptor} from "../../lib/csrf_interceptor";

import * as CustomAPIS from "../../lib/apis"
import { ConfirmationManager, ConfirmationWrapper } from './modal/Confirmation';
import { ModalManager, ModalManagerInterface } from './modal/modal_manager';

const enLocaleData = require('react-intl/locale-data/en');
const deLocaleData = require('react-intl/locale-data/de');
const I18n = require('i18n')

addLocaleData([...enLocaleData, ...deLocaleData])

interface RootProps
{

}

const RootWrapper:React.StatelessComponent<{children: React.ReactNode[]|React.ReactNode, confirmationManager:ConfirmationManager}> = (props) => {
  return <>
            {props.children}
            <ConfirmationWrapper confirmationAccessor={props.confirmationManager}/>
  </>
}

RootWrapper.displayName = "RootWrapper"

@observer
export default class Root extends React.Component<RootProps, {}> {

  apiManager: ApiManager
  confirmationManager: ConfirmationManager
  modalManager:ModalManagerInterface

  componentDidMount(){
    let pageProgress = (window as any).pageProgress
    if (pageProgress && pageProgress.finishPageLoad){
      pageProgress.finishPageLoad()
    }

  }
  render() {
    if (!this.apiManager){
      this.apiManager = new ApiManager(APIS.concat(CustomAPIS.APIS as Array<any>), CSRFInterceptor)
    }
    if(!this.confirmationManager)
      this.confirmationManager = new ConfirmationManager();
    if(!this.modalManager)
      this.modalManager = new ModalManager()

    return <IntlProvider locale={I18n.locale} defaultLocale={I18n.defaultLocale} messages={convert(I18n.translations[I18n.locale])}>
       <Provider ApiManager={this.apiManager} ConfirmationManager={this.confirmationManager} ModalManager={this.modalManager}>
         <RootWrapper confirmationManager={this.confirmationManager}>
            {this.props.children}
         </RootWrapper>
       </Provider>
      </IntlProvider>
     
  }
}





