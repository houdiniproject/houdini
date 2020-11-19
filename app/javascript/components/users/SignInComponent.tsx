// License: LGPL-3.0-or-later
import React, { useEffect, useState } from "react";
import { createStyles, Theme, makeStyles } from '@material-ui/core/styles';
import { Formik, Form, Field } from 'formik';
import noop from "lodash/noop";
import usePrevious from 'react-use/lib/usePrevious';
import { spacing } from '@material-ui/system';
import MuiButton from "@material-ui/core/Button";
import { styled } from "@material-ui/core/styles";
import CircularProgress from '@material-ui/core/CircularProgress';
import InputAdornment from '@material-ui/core/InputAdornment';
import AccountCircle from '@material-ui/icons/AccountCircle';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import { TextField } from 'formik-material-ui';
import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import { SignInError } from '../../legacy_react/src/lib/api/errors';
import { useIntl } from "../../components/intl";
import useYup from '../../hooks/useYup';
import Box from '@material-ui/core/Box';
import Alert from '@material-ui/lab/Alert';
import { useId } from "@reach/auto-id";

export interface SignInComponentProps {
	/**
	 * An attempt at signing in failed
	 *
	 * @memberof SignInComponentProps
	 */
	onFailure?: (error: SignInError) => void;
	onSubmitting?: () => void;
	onSuccess?: () => void;
}

function SignInComponent(props: SignInComponentProps): JSX.Element {
	const [componentState, setComponentState] = useState<'ready' | 'canSubmit' | 'submitting' | 'success'>('ready');
	const [isValid, setIsValid] = useState(false);

	const { currentUser, signIn, lastError, failed, submitting } = useCurrentUserAuth();
	// this keeps track of what the values submitting were the last
	// time the the component was rendered
	const previousSubmittingValue = usePrevious(submitting);

	useEffect(() => {
		// was the component previously submitting and now not submitting?
		const wasSubmitting = previousSubmittingValue && !submitting;

		if (failed && wasSubmitting) {
			// we JUST failed so we only call onFailure
			// once
			setComponentState('ready');
			props.onFailure(lastError);
		}

		if (wasSubmitting && !failed) {
			// we JUST succeeded
			// TODO
			setComponentState('success');
			props.onSuccess();
		}
	}, [failed, submitting, previousSubmittingValue, lastError]);

	useEffect(() => {
		if (isValid && submitting) {
			setComponentState('submitting');
			props.onSubmitting();
		}
	}, [submitting]);

	useEffect(() => {
		if (isValid && componentState == 'ready') {
			setComponentState('canSubmit');
		}
	}, [isValid, componentState]);

	//Setting error messages
	const { formatMessage } = useIntl();
	const yup = useYup();
	const passwordLabel = formatMessage({ id: 'login.password' });
	const emailLabel = formatMessage({ id: 'login.email' });
	const successLabel = formatMessage({ id: 'login.success' });
	const loginHeaderLabel = formatMessage({ id: 'login.header' });
	const emailId = useId();
	const passwordId = useId();

	//Yup validation
	const validationSchema = yup.object({
		email: yup.string().label(emailLabel).email().required(),
		password: yup.string().label(passwordLabel).required(),
	});

	//Styling - Material-UI
	const useStyles = makeStyles((theme: Theme) => createStyles({
		textField: {
			'& .MuiTextField-root': {
				margin: theme.spacing(1),
			},
		},
		paper: {
			maxWidth: 400,
			margin: `${theme.spacing(1)}px auto`,
			padding: theme.spacing(2),
			borderRadius: 15,
		},
		box: {
			justify: "center",
			alignContent: "center",
			display: "flex",
		},
		buttonProgress: {
			position: 'absolute',
		},
		submitButton: {
			height: 40,
		},
	}),
	);
	const Button = styled(MuiButton)(spacing);
	const classes = useStyles();

	//Formik
	return (
		<Formik
			initialValues={
				{
					email: "",
					password: "",
				}}
			validationSchema={validationSchema}
			onSubmit={async (values, formikHelpers) => {
				try {
					await signIn(values);
				}
				catch (e: unknown) {
					// NOTE: We're just swallowing the exception here for now. Might we need to do
					// something different? Don't know!
				}
				finally {
					formikHelpers.setSubmitting(false);
				}
			}
				//Props
			}>{({ isValid }) => {
				// eslint-disable-next-line react-hooks/rules-of-hooks
				useEffect(() => {
					setIsValid(isValid);
				}, [isValid]);

				//Form
				return (
					<Form>
						{/* NOTE: if a Button should submit a form, mark it as type="submit". Otherwise pressing Enter won't submit form*/}
						<Box display="flex" justifyContent="center" alignItems="center">
							{componentState !== 'success' ?
								<Box p={1.5}>
									<Field component={TextField} name="email" type="text" id={emailId} data-testid="emailInput"
										label={emailLabel}
										InputProps={{
											startAdornment: (
												<InputAdornment position="start">
													<AccountCircle fontSize="small" />
												</InputAdornment>
											),
										}}
									/>
								</Box>
								: null}
						</Box>errors
						<Box display="flex" justifyContent="center" alignItems="center">
							{componentState !== 'success' ?
								<Box p={1.5}>
									<Field component={TextField} name="password" type="password" id={passwordId}
										label={passwordLabel}
										InputProps={{
											startAdornment: (
												<InputAdornment position="start">
													<LockOpenIcon fontSize="small" />
												</InputAdornment>
											),
										}} />
								</Box>
								: null}
						</Box>
						<Box display="flex" justifyContent="center" alignItems="center">
							{componentState === 'submitting' ? "" : <>
								{failed ? lastError.data.error.map((error) => (<Alert severity="error" key={error}>{error}</Alert>)) : ""}
							</>
							}
						</Box>
						{componentState !== 'success' ?
							<Box p={2} display="flex" justifyContent="center" alignItems="center">
								{componentState !== 'submitting' ?
									<Button className={classes.submitButton}
										data-testid="signInButton"
										type="submit"
										color="primary"
										variant='contained'
										disabled={!isValid}
									>
										{loginHeaderLabel}
									</Button>
									: ""}
								{/* Circular progress on submit button */}
								{submitting && <CircularProgress size={24} className={classes.buttonProgress} />}
							</Box>
							: null}
						{componentState == 'success' && currentUser ?
							<Box m={13} display="flex" justifyContent="center" alignItems="center">
								<p><Alert severity="success">{successLabel}</Alert></p>
							</Box>
							: null}
					</Form>
				);
			}}
		</Formik>
	);
}

SignInComponent.defaultProps = {
	// default onFailure to noop so you don't have to check whether onFailure is
	// set inside the component before calling it
	onFailure: noop,
	onSuccess: noop,
	onSubmitting: noop,
};

export default SignInComponent;