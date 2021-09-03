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
import useIsLoading from "../../hooks/useIsLoading";
import useIsReadyForSubmission from "../../hooks/useIsReadyForSubmission";
import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import useForm from "../../hooks/useForm";
import { useIntl } from "../../components/intl";
import useYup from '../../hooks/useYup';
import Box from '@material-ui/core/Box';
import Alert from '@material-ui/lab/Alert';
import { useId } from "@reach/auto-id";
import AnimatedCheckmark from '../common/progress/AnimatedCheckmark';
import { NetworkError } from "../../api/errors";


export interface SignInComponentProps {
	/**
	 * An attempt at signing in failed
	 *
	 * @memberof SignInComponentProps
	 */
	onFailure?: (error: NetworkError) => void;
	onSubmitting?: () => void;
	onSuccess?: () => void;
	showProgressAndSuccess?: boolean;
}

function hasData(error: unknown): error is { data: unknown } {
	return Object.prototype.hasOwnProperty.call(error, 'data');
}

function hasDataValue(error: { data: unknown }): boolean {
	return error.data !== null && error.data !== undefined;
}

function hasError(error: { data: unknown }): error is { data: { error: unknown } } {
	return Object.prototype.hasOwnProperty.call(error.data, 'error');
}

function FailedAlert({ error }: { error: unknown }): JSX.Element {
	if (hasData(error)) {
		if (hasDataValue(error)) {
			if (hasError(error)) {
				if (error.data.error instanceof Array) {
					return <>{error.data.error.map((error) => (<Alert aria-labelledby="errorTest" severity="error" key={error}>{error}</Alert>))}</>;
				}
				else if (typeof error.data.error === 'string') {
					return <Alert aria-labelledby="errorTest" severity="error" key={error.data.error}>{error.data.error}</Alert>;
				}
			}
		}
	}
	return <Alert aria-labelledby="errorTest" severity="error" key={'unknownerror'}>An unknown error occurred</Alert>;
}


function SignInComponent(props: SignInComponentProps): JSX.Element {
	const [isValid, setIsValid] = useState(false);

	const { currentUser, signIn, lastSignInAttemptError, failed, submitting } = useCurrentUserAuth();
	// this keeps track of what the values submitting were the last
	// time the the component was rendered
	const previousSubmittingValue = usePrevious(submitting);
	const wasSubmitting = previousSubmittingValue && !submitting;
	const { onSuccess, onFailure, onSubmitting, showProgressAndSuccess } = props;
	const loading = useIsLoading(submitting, showProgressAndSuccess);
	// <'ready' | 'canSubmit' | 'submitting' | 'success'>
	const formState = useForm(
		wasSubmitting,
		onFailure,
		onSuccess,
		onSubmitting,
		isValid
	);
	const canSubmit = useIsReadyForSubmission(isValid, showProgressAndSuccess, formState);

	//Setting error messages
	const { formatMessage } = useIntl();
	const yup = useYup();
	const passwordLabel = formatMessage({ id: 'login.password' });
	const emailLabel = formatMessage({ id: 'login.email' });
	// const successLabel = formatMessage({ id: 'login.success' });
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
		backdrop: {
			zIndex: theme.zIndex.drawer + 1,
			color: '#fff',
			cursor: 'none',
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
		checkmark: {
			color: theme.palette.success.main,
			fontSize: 100,
		},
	}),
	);
	const Button = styled(MuiButton)(spacing);
	const classes = useStyles();

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

				setIsValid(isValid);


				//Form
				return (
					<Form>
						{/* NOTE: if a Button should submit a form, mark it as type="submit". Otherwise pressing Enter won't submit form*/}
						<Box display="flex" justifyContent="center" alignItems="center">
							{formState !== 'success' ?
								<Box p={1.5}>
									<Field component={TextField} name="email" type="text" id={emailId} data-testid="emailTest"
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
						</Box>
						<Box display="flex" justifyContent="center" alignItems="center">
							{formState !== 'success' ?
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
						<div data-testid="errorTest">
							<Box display="flex" justifyContent="center" alignItems="center">
								{formState === 'submitting' ? "" : <>
									{failed ? <FailedAlert error={lastSignInAttemptError} /> : ""}
								</>
								}
							</Box>
						</div>
						{formState !== 'success' ?
							<Box p={2} display="flex" justifyContent="center" alignItems="center">
								{loading ?
									(<div data-testid="progressTest">
										<Box display="flex" justifyContent="center" alignItems="center">
											<CircularProgress size={25} className={classes.buttonProgress} />
										</Box>
									</div>) :
									<Button className={classes.submitButton}
										data-testid="signInButton"
										type="submit"
										color="primary"
										variant='contained'
										disabled={!canSubmit}
									>
										{loginHeaderLabel}
									</Button>}
							</Box>
							: null}
						<div data-testid="signInComponentSuccess">
							{formState === 'success' && currentUser && showProgressAndSuccess ?
								<Box m={13} display="flex" justifyContent="center" alignItems="center">
									<AnimatedCheckmark ariaLabel={"login.success"} role={"status"} />
								</Box>
								: null}
						</div>
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