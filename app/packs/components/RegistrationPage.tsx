import React from "react"
require('bootstrap-loader');
import Root from "../legacy_react/src/components/common/Root"
import RegPage from "../legacy_react/src/components/registration_page/RegistrationPage"


function RegistrationPage(props:{}){
  return (<Root><RegPage/></Root>)
}

export default RegistrationPage
