// License: LGPL-3.0-or-later
import React, { MutableRefObject, useEffect, useReducer, useRef } from "react";
import { createStyles, Theme, makeStyles } from '@material-ui/core/styles';
import noop from "lodash/noop";
import CircularProgress from '@material-ui/core/CircularProgress';
import InputAdornment from '@material-ui/core/InputAdornment';
import AccountCircle from '@material-ui/icons/AccountCircle';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import { useIntl } from "../../components/intl";
import useYup from '../../hooks/useYup';
import Box from '@material-ui/core/Box';
import Alert from '@material-ui/lab/Alert';
import { useId } from "@reach/auto-id";
import AnimatedCheckmark from '../common/progress/AnimatedCheckmark';
import { NetworkError } from "../../api/errors";
import { Button } from "@material-ui/core";
import { ClassNameMap } from "@material-ui/core/styles/withStyles";
import { useForm, UseFormReturn } from "react-hook-form";
import { yupResolver } from '@hookform/resolvers/yup';
import TextField from "../form_fields/TextField";
import { useMountedState, usePrevious } from "react-use";




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

type SignInComponentStates = 'isReady' | 'isSubmitting' | 'canSubmit' | 'isLoading' | 'isSuccessful' | '';

interface ComponentState {
	previousState: SignInComponentStates | null;
	state: SignInComponentStates;
}

type Action = {
	//previousState: SignInComponentStates | null;
	state: SignInComponentStates;
	type: 'SET_STATE';
} | {
	type: 'PROCESSED_EVENTS';
};

function signInComponentReducer(state: ComponentState, action: Action) {
	switch (action.type) {
		case 'SET_STATE':
			return { state: action.state, previousState: state.state };
		case 'PROCESSED_EVENTS':
			return { ...state, previousState: state.state };
	}
}


interface DispatchInput {
	failed: boolean;
	isValid: boolean;
	lastSignInAttemptError?: NetworkError | null;
	onFailure: (e: NetworkError) => void;
	onSubmitting: () => void;
	onSuccess: () => void;
	signedIn: boolean;
	submitting: boolean;
	touched: boolean;
}

function useValueAsRef<T>(value: T): MutableRefObject<T> {
	const handlerRef = useRef(value);
	handlerRef.current = value;
	return handlerRef;
}

function useStateAndEventDispatch({ submitting, isValid, touched, signedIn, ...props }: DispatchInput): SignInComponentStates {

	const [{ state, previousState }, dispatchChange] = useReducer(signInComponentReducer, { state: 'isReady', previousState: '' });

	const signInErrorRef = useValueAsRef(props.lastSignInAttemptError!);
	const onSubmittingRef = useValueAsRef(props.onSubmitting);
	const onSuccessRef = useValueAsRef(props.onSuccess);
	const onFailureRef = useValueAsRef(props.onFailure);
	const previousSubmitting  = usePrevious(submitting);
	const isMounted = useMountedState();

	useEffect(() => {
		if (state == 'isSubmitting' && previousState !== 'isSubmitting') {
			if (isMounted())
				onSubmittingRef.current();
		}
		else if (previousState == 'isSubmitting' && state != 'isSubmitting' && state !== 'isSuccessful') {
			if (isMounted())
				onFailureRef.current(signInErrorRef.current);
		}
		else if (previousState != 'isSuccessful' && state === 'isSuccessful') {
			if (isMounted())
				onSuccessRef.current();
		}

		dispatchChange({ type: 'PROCESSED_EVENTS' });
	}, [state, previousState, onSubmittingRef, signInErrorRef, onSuccessRef, onFailureRef, isMounted]);

	useEffect(() => {
		if (submitting) {
			if (isMounted())
				dispatchChange({ type: 'SET_STATE', state: "isSubmitting" });
		}
	}, [submitting, isMounted]);

	useEffect(() => {
		if (isValid && touched && state === 'isReady') {
			if (isMounted())
				dispatchChange({ type: 'SET_STATE', state: 'canSubmit' });
		}
	}, [isValid, touched, state, isMounted]);

	useEffect(() => {
		if (signedIn) {
			if (isMounted())
				dispatchChange({ type: 'SET_STATE', state: 'isSuccessful' });
		}
	}, [signedIn, isMounted]);

	useEffect(() => {
		if (!submitting && previousSubmitting && !signedIn) {
			if (isMounted) {
				dispatchChange({type: 'SET_STATE', state: 'isReady'});
			}
		}
	}, [submitting, previousSubmitting, signedIn, isMounted]);

	return state;
}


function SignInComponent(props: SignInComponentProps): JSX.Element {
	const { signIn, lastSignInAttemptError, failed, submitting, signedIn } = useCurrentUserAuth();
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
	//const isMounted = useMountedState();
	const form = useForm({
		mode: 'all',
		resolver: yupResolver(validationSchema),
		defaultValues: { email: '', password: '' },

	});
	return (
		<form onSubmit={form.handleSubmit(async (data) => {
			try {
				await signIn(data);
			}
			catch (e: unknown) {
				// NOTE: We're just swallowing the exception here for now. Might we need to do
				// something different? Don't know!
			}
		})}>
			<InnerFormComponent
				emailLabel={emailLabel}
				passwordLabel={passwordLabel}
				failed={failed}
				lastSignInAttemptError={lastSignInAttemptError!}
				classes={classes}
				loginHeaderLabel={loginHeaderLabel}
				submitting={submitting}
				onFailure={onFailure!}
				onSubmitting={onSubmitting!}
				onSuccess={onSuccess!}
				showProgressAndSuccess={showProgressAndSuccess!}
				signedIn={signedIn}
				form={form}
			/>
		</form>
	);
}


function InnerFormComponent<TFieldValues>(props: {
	classes: ClassNameMap<"textField" | "paper" | "backdrop" | "box" | "buttonProgress" | "submitButton" | "checkmark">;
	emailLabel: string;
	failed: boolean;
	form: UseFormReturn<TFieldValues>;
	lastSignInAttemptError: NetworkError;
	loginHeaderLabel: string;
	onFailure: (error: NetworkError) => void;
	onSubmitting: () => void;
	onSuccess: () => void;
	passwordLabel: string;
	showProgressAndSuccess: boolean;
	signedIn: boolean;
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
		signedIn,
		form: { formState: { isDirty: touched, isValid }, control },
	} = props;




	const state = useStateAndEventDispatch({
		failed,
		onFailure,
		onSuccess,
		onSubmitting,
		lastSignInAttemptError,
		touched,
		isValid,
		submitting,
		signedIn,
	});

	const canSubmit = state === 'canSubmit';
	const isLoading = state === 'isSubmitting';
	const isSuccessful = state === 'isSuccessful';

	const emailId = useId();
	const passwordId = useId();

	return (
		<>
			<Box display="flex" justifyContent="center" alignItems="center">
				{!isSuccessful ?
					<Box p={1.5}>
						<TextField control={control} id={emailId} name="email" data-testid="emailTest"
							label={emailLabel}
							InputProps={{
								startAdornment: (
									<InputAdornment position="start">
										<AccountCircle fontSize="small" />
									</InputAdornment>
								),
							}} />
					</Box>
					: null}
			</Box>
			<Box display="flex" justifyContent="center" alignItems="center">
				{!isSuccessful ?
					<Box p={1.5}>
						<TextField control={control}
							id={passwordId}
							name="password"
							label={passwordLabel}
							type="password"
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
					{isLoading ? "" : <>
						{failed ? <FailedAlert error={lastSignInAttemptError} /> : ""}
					</>
					}
				</Box>
			</div>
			{!isSuccessful ?
				<Box p={2} display="flex" justifyContent="center" alignItems="center">
					{isLoading && showProgressAndSuccess ?
						(<div data-testid="progressTest">
							<Box display="flex" justifyContent="center" alignItems="center">
								<CircularProgress size={25} className={classes.buttonProgress} aria-label={"Signing In..."} />
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
				{isSuccessful && showProgressAndSuccess ?
					<Box m={13} display="flex" justifyContent="center" alignItems="center">
						<AnimatedCheckmark ariaLabel={"login.success"} role={"status"} />
					</Box>
					: null}
			</div>
		</>
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
