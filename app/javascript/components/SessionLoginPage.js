import React from "react"
require('bootstrap-loader');
import Root from "../legacy_react/src/components/common/Root"
import SessionLogPage from "../legacy_react/src/components/session_login_page/SessionLoginPage"


function SessionLoginPage(props:{}){
  return (<Root><SessionLogPage/></Root>)
}

export default SessionLoginPage
