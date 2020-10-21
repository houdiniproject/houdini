// License: LGPL-3.0-or-later
import React, {useEffect} from "react";
import {Formik, Form} from 'formik';
import Button from '@material-ui/core/Button';
import noop from "lodash/noop";

import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import { SignInError } from "../../legacy_react/src/lib/api/errors";


interface SignInComponentProps {
	/**
	 * An attempt at signing in failed
	 *
	 * @memberof SignInComponentProps
	 */
	onFailure?:(error:SignInError) =>  void;
}

// NOTE: Remove this line and next once you start using the props argument
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function SignInComponent(props:SignInComponentProps) : JSX.Element {
	const {currentUser, signIn, lastError, failed}  = useCurrentUserAuth();
	useEffect(() => {
		if (failed) {
			props.onFailure(lastError);
		}
	}, [failed]);

	return (
		<Formik initialValues={{}} onSubmit={async (_values, formikHelpers) => {
			try {
				await signIn({email: 'email@ema.com', password: "password"});
			}
			catch (e:unknown) {
				// NOTE: We're just swallowing the exception here. Might we need to do
				// something different? Don't know!
			}
			finally {
				formikHelpers.setSubmitting(false);
			}
		}
		}>
			<Form>
				{/* NOTE: if a Button should submit a form, mark it as type="submit". Otherwise pressing Enter won't submit form*/}
				<Button data-testid="signInButton" type="submit" >Run the test!</Button>
				<div data-testid="signInErrorDiv">{lastError?.data ? lastError.data.map((i) => i.error).join('; ') : ""}</div>
				<div data-testid="currentUserDiv">{currentUser ? currentUser.id : ""}</div>
			</Form>
		</Formik>
	);
}

SignInComponent.defaultProps = {
	onFailure: noop,
};

export default SignInComponent;