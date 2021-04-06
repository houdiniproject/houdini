// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root";
import SessionLoginPageInner from "../src/components/session_login_page/SessionLoginPage";

import React from 'react';

function SessionLoginPage() :JSX.Element {
	return (<Root><SessionLoginPageInner/></Root>);
}


export default SessionLoginPage;