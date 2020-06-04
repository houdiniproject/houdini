// License: LGPL-3.0-or-later

// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import RegistrationPage from "../src/components/registration_page/RegistrationPage"

import * as ReactDOM from 'react-dom'
import * as React from 'react'

function LoadReactPage(element:HTMLElement) {
  ReactDOM.render(<Root><RegistrationPage/></Root>, element)
}


(window as any).LoadReactPage = LoadReactPage

