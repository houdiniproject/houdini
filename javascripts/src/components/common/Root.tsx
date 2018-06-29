// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer, Provider} from 'mobx-react';
import {addLocaleData, IntlProvider} from 'react-intl';
import {convert} from 'dotize'
import {ApiManager} from "../../lib/api_manager";
import {APIS} from "../../../api";
import {CSRFInterceptor} from "../../lib/csrf_interceptor";

import * as CustomAPIS from "../../lib/apis"

const enLocaleData = require('react-intl/locale-data/en');
const deLocaleData = require('react-intl/locale-data/de');
const I18n = require('i18n')

addLocaleData([...enLocaleData, ...deLocaleData])

interface RootProps
{

}


@observer
export default class Root extends React.Component<RootProps, {}> {

  apiManager: ApiManager

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

    return <IntlProvider locale={I18n.locale} defaultLocale={I18n.defaultLocale} messages={convert(I18n.translations[I18n.locale])}>
       <Provider ApiManager={this.apiManager}>
          {this.props.children}
       </Provider>
      </IntlProvider>
  }
}





