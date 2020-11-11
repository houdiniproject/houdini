// License: LGPL-3.0-or-later
import React, { useEffect, useState } from "react";
import { createStyles, Theme, makeStyles } from '@material-ui/core/styles';
import { Formik, Form,  Field } from 'formik';
import noop from "lodash/noop";
import usePrevious from 'react-use/lib/usePrevious';
import { spacing } from '@material-ui/system';
import MuiButton from "@material-ui/core/Button";
import { styled } from "@material-ui/core/styles";
import CircularProgress from '@material-ui/core/CircularProgress';
import InputAdornment from '@material-ui/core/InputAdornment';
import AccountCircle from '@material-ui/icons/AccountCircle';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import {TextField} from 'formik-material-ui';
import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import { SignInError } from '../../legacy_react/src/lib/api/errors';
import { useIntl } from "../../components/intl";
import useYup from '../../hooks/useYup';
import Box from '@material-ui/core/Box';
import Alert from '@material-ui/lab/Alert';




export interface SignInComponentProps {
	/**
	 * An attempt at signing in failed
	 *
	 * @memberof SignInComponentProps
	 */
	onFailure?: (error: SignInError) => void;
}

function SignInComponent(props: SignInComponentProps): JSX.Element {
	const [componentState, setComponentState] = useState<'ready' | 'canSubmit' | 'submitting' | 'success'>('ready');
  const [isValid, setIsValid] = useState(false);
  const timer = React.useRef<number>(); //Circular progress timer

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
		}
	}, [failed, submitting, previousSubmittingValue]);

	useEffect(() => {
		if (isValid && submitting) {
			setComponentState('submitting');
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
	const passwordLabel = formatMessage({id: 'login.password'});
  const emailLabel = formatMessage({id: 'login.email'});
  const successLabel = formatMessage({id: 'login.success'});
  const emailValidLabel = formatMessage({id: 'login.errors.password_email'});
  const loginHeaderLabel = formatMessage({id: 'login.header'});

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

//Circular progress timer
  React.useEffect(() => {
    return () => {
      clearTimeout(timer.current);
    };
  }, []);

//Handles submit button
  const handleButtonClick = () => {
    if (!submitting) {
      timer.current = window.setTimeout(() => {
      }, 2000);
    }
  };


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
        }>{({ errors, isValid, touched, handleChange }) => {
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
                <Field component={TextField} name="email" type="text"
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
            : null }
            </Box>
            <Box display="flex" justifyContent="center" alignItems="center">
            {componentState !== 'success' ? 
              <Box p={1.5}>
                <Field component={TextField} name="password" type="password"
                  label={passwordLabel}
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <LockOpenIcon fontSize="small" />
                      </InputAdornment>
                    ),
                  }} />
              </Box>
            : null }
            </Box>
            <Box display="flex" justifyContent="center" alignItems="center">
              {componentState === 'submitting' ? "" : <>
              {failed ? <Alert severity="error">{emailValidLabel}</Alert> : ""}
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
                    onClick={handleButtonClick}
                  > 
                      <p>{loginHeaderLabel}</p>
                </Button>
                : "" }
                {/* Circular progress on submit button */}
                {submitting && <CircularProgress size={24} className={classes.buttonProgress} />}
              </Box>
            : null }
            <Box p={2} display="flex" justifyContent="center" alignItems="center">
              {componentState == 'success' && currentUser ?
                    <p><Alert severity="success">{successLabel}</Alert></p>
                  : null }
            </Box>
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
};

export default SignInComponent;