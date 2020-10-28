// License: LGPL-3.0-or-later
import React, {useEffect, useState} from "react";
import {Formik, Form, Field} from 'formik';
import Button from '@material-ui/core/Button';
import noop from "lodash/noop";
import usePrevious from 'react-use/esm/usePrevious';
import * as EmailValidator from "email-validator"; 
import { TextField } from 'formik-material-ui/core';
import { Link } from '@material-ui/core';


import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import { SignInError } from "../../legacy_react/src/lib/api/errors";
import { useIntl } from "../../components/intl";
import * as yup from '../../common/yup';
import { Email } from '../../legacy_react/src/lib/regex';


export interface SignInComponentProps {
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
	const [componentState, setComponentState] = useState<'ready'|'canSubmit'|'submitting'|'success'>('ready');
	const [isValid, setIsValid] = useState(false);

	const {currentUser, signIn, lastError, failed, submitting}  = useCurrentUserAuth();

	// this keeps track of what the values submitting were the last
	// time the the component was rendered
	const previousSubmittingValue = usePrevious(submitting);

	useEffect(() => {
		// was the component previously submitting and now not submitting?
		const wasSubmitting = previousSubmittingValue && !submitting;

		if (failed && wasSubmitting) {
			// we JUST failed so we only call onFailure
			// once
			props.onFailure(lastError);
		}

		if (wasSubmitting && !failed){
			// we JUST succeeded
			// TODO
		}
	}, [failed, submitting, previousSubmittingValue]);

	useEffect(() => {
		if (submitting) {
			setComponentState('submitting');
		}
	}, [submitting]);

	useEffect(() => {
		if (isValid && componentState == 'ready') {
			setComponentState('canSubmit');
		}
	}, [isValid, componentState]);

	const { formatMessage } = useIntl();

	const validationSchema= yup.object({
		email: yup.string().required(),
		password: yup.string()
		  .required()
	  });

	return (
		<Formik initialValues={{email: ""}}  onSubmit={async (_values, formikHelpers) => {
			try {
				await signIn({email: 'email@ema.com', password: "password"});
			}
			catch (e:unknown) {
				// NOTE: We're just swallowing the exception here for now. Might we need to do
				// something different? Don't know!
			}
			finally {
				formikHelpers.setSubmitting(false);
			}
		}
		}>{(props) => {
				useEffect(() => {
					setIsValid(props.isValid);
				}, [props.isValid]);

				return <Form>
					{/* NOTE: if a Button should submit a form, mark it as type="submit". Otherwise pressing Enter won't submit form*/}
					<Field
						component={TextField}
						name="email"
						type="email"
						label="Email"
					/>
					<br />
					<Field
						component={TextField}
						type="password"
						label="Password"
						name="password"
					/>
					<br />
					<br />
            <Button data-testid="signInButton" type="submit"
              variant={'contained'}
              color={'primary'}>{formatMessage({id: 'submit'})}
            </Button>
            <br />
            <br />
            <Link
              component="button"
              variant="body2"
              onClick={() => {
                console.info("I'm a button.");
              }}
            >
              Button Link
          </Link>


					{componentState === 'submitting' ? "" : <>
						<div data-testid="signInErrorDiv">{ failed ? lastError.data.error.map((i) => i).join('; ') : ""}</div>
						<div data-testid="currentUserDiv">{currentUser ? currentUser.id : ""}</div>
					</>
					}
				</Form>;
			}}

		</Formik>
	);
}

SignInComponent.defaultProps = {
	// default onFailure to noop so you don't have to check whether onFailure is
	// set inside the component before calling it
	onFailure: noop,
};

export default SignInComponent;