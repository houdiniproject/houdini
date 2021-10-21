// License: LGPL-3.0-or-later
import React, { useEffect, useState } from "react";
import { createStyles, Theme, makeStyles } from '@material-ui/core/styles';
import { Formik, Form, Field, useFormikContext } from 'formik';
import noop from "lodash/noop";
import usePrevious from 'react-use/lib/usePrevious';
import CircularProgress from '@material-ui/core/CircularProgress';
import InputAdornment from '@material-ui/core/InputAdornment';
import AccountCircle from '@material-ui/icons/AccountCircle';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import { TextField } from 'formik-material-ui';
import useIsLoading from "../../hooks/useIsLoading";
import useIsSuccessful from "../../hooks/users/useIsSuccessful";
import useIsReady from "../../hooks/users/useIsReady";
import useCanSubmit from "../../hooks/useCanSubmit";
import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import useIsSubmitting from "../../hooks/users/useIsSubmitting";
import { useIntl } from "../../components/intl";
import useYup from '../../hooks/useYup';
import Box from '@material-ui/core/Box';
import Alert from '@material-ui/lab/Alert';
import { useId } from "@reach/auto-id";
import AnimatedCheckmark from '../common/progress/AnimatedCheckmark';
import { NetworkError } from "../../api/errors";
import { Button } from "@material-ui/core";
import { useMountedState } from "react-use";
import { ClassNameMap } from "@material-ui/core/styles/withStyles";


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
	const { signIn, lastSignInAttemptError, failed, submitting } = useCurrentUserAuth();
	const { onSuccess, onFailure, onSubmitting, showProgressAndSuccess } = props;

	//Setting error messages
	const { formatMessage } = useIntl();
	const passwordLabel = formatMessage({ id: 'login.password' });
	const emailLabel = formatMessage({ id: 'login.email' });
	const loginHeaderLabel = formatMessage({ id: 'login.header' });

	//Yup validation
	const yup = useYup();
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
	const classes = useStyles();
	const isMounted = useMountedState();

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
					if (isMounted()) formikHelpers.setSubmitting(false);
				}
			}
				//Props
			}>{() => {

				return (<InnerFormikComponent
					emailLabel={emailLabel}
					passwordLabel={passwordLabel}
					failed={failed}
					lastSignInAttemptError={lastSignInAttemptError}
					classes={classes}
					loginHeaderLabel={loginHeaderLabel}
					submitting={submitting}
					onFailure={onFailure}
					onSubmitting={onSubmitting}
					onSuccess={onSuccess}
					showProgressAndSuccess={showProgressAndSuccess}
				/>);
			}}
		</Formik>
	);
}

function InnerFormikComponent(props: {
	classes: ClassNameMap<"textField" | "paper" | "backdrop" | "box" | "buttonProgress" | "submitButton" | "checkmark">;
	emailLabel: string;
	failed: boolean;
	lastSignInAttemptError: NetworkError;
	loginHeaderLabel: string;
	onFailure: (error: NetworkError) => void;
	onSubmitting: () => void;
	onSuccess: () => void;
	passwordLabel: string;
	showProgressAndSuccess: boolean;
	submitting: boolean;
}) {
	const {
		submitting,
		onFailure,
		failed,
		lastSignInAttemptError,
		showProgressAndSuccess,
		onSubmitting,
		onSuccess,
		emailLabel,
		passwordLabel,
		loginHeaderLabel,
		classes,
	} = props;
	const [, setIsValid] = useState(false);
	const [, setTouched] = useState(false);
	const { isValid } = useFormikContext();
	useEffect(() => {
		setIsValid(isValid);
	}, [isValid, setIsValid]);

	const { dirty } = useFormikContext();
	useEffect(() => {
		setTouched(dirty);
	}, [dirty, setTouched]);

	// this keeps track of what the values submitting were the last
	// time the the component was rendered
	const previousSubmittingValue = usePrevious(submitting);
	const wasSubmitting = previousSubmittingValue && !submitting;

	const isReady = useIsReady(wasSubmitting, onFailure, failed, lastSignInAttemptError, submitting);
	const canSubmit = useCanSubmit(isValid, showProgressAndSuccess, isReady, dirty);
	const loading = useIsLoading(submitting, showProgressAndSuccess);
	const isSubmitting = useIsSubmitting(onSubmitting, isValid, submitting);
	const isSuccessful = useIsSuccessful(showProgressAndSuccess, onSuccess);

	const emailId = useId();
	const passwordId = useId();

	return (
		<Form>
			{/* NOTE: if a Button should submit a form, mark it as type="submit". Otherwise pressing Enter won't submit form*/}
			<Box display="flex" justifyContent="center" alignItems="center">
				{!isSuccessful ?
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
				{!isSuccessful ?
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
					{isSubmitting ? "" : <>
						{failed ? <FailedAlert error={lastSignInAttemptError} /> : ""}
					</>
					}
				</Box>
			</div>
			{!isSuccessful ?
				<Box p={2} display="flex" justifyContent="center" alignItems="center">
					{loading ?
						(<div data-testid="progressTest">
							<Box display="flex" justifyContent="center" alignItems="center">
								<CircularProgress size={25} className={classes.buttonProgress} aria-label={"Signing In..."}/>
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
				{isSuccessful ?
					<Box m={13} display="flex" justifyContent="center" alignItems="center">
						<AnimatedCheckmark ariaLabel={"login.success"} role={"status"} />
					</Box>
					: null}
			</div>
		</Form>
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