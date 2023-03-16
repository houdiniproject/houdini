
// License: LGPL-3.0-or-later
import * as React from 'react';

export interface ErrorDivDetailsProps {
  isValid: boolean
  hasServerError: boolean
  serverError?: string | null
}

function AlertInnerHtmlContents({serverError}:{serverError:string}): JSX.Element {
  if (!serverError) {
    return <> </>;
  }
  else if (!serverError.includes("locked")) {
    return <>{serverError}</>
  }
  else {
    return (<>{serverError}&nbsp;
        You should have received an email with instructions on how to unlock your account.&nbsp;
        If you need to resend this email, you can do so <a href="/users/unlock/new">here</a>.
    </>);
  }


}

export function ErrorDivDetails({isValid, hasServerError, serverError}:ErrorDivDetailsProps) : JSX.Element {
  if (!isValid || hasServerError) {
    
    return (<div className="form-group has-error">
        <div className="help-block" role="alert">
          <AlertInnerHtmlContents serverError={serverError}/>
        </div>
      </div>)
  }
  else 
    return <> </>;
}