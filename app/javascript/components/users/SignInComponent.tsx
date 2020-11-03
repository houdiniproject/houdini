// License: LGPL-3.0-or-later
import React, { useEffect, useState } from "react";
import { createStyles, Theme, makeStyles, useTheme } from '@material-ui/core/styles';
import { Formik, Form, FormikErrors, Field, useFormik, ErrorMessage, ErrorMessageProps } from 'formik';
import Button from '@material-ui/core/Button';
import noop from "lodash/noop";
import usePrevious from 'react-use/esm/usePrevious';
import Typography from '@material-ui/core/Typography';
import { spacing } from '@material-ui/system';
import MuiButton from "@material-ui/core/Button";
import { styled } from "@material-ui/core/styles";
import Grid from '@material-ui/core/Grid';
import { shadows } from '@material-ui/system';
import logo from './Images/HoudiniLogo.png';


import { CardContent, Link } from '@material-ui/core';
import InputLabel from '@material-ui/core/InputLabel';
import InputAdornment from '@material-ui/core/InputAdornment';
import AccountCircle from '@material-ui/icons/AccountCircle';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import Input from '@material-ui/core/Input';
import Card from '@material-ui/core/Card';
import CardMedia from "@material-ui/core/CardMedia";
import TextField from '@material-ui/core/TextField';
import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import { SignInError } from "../../legacy_react/src/lib/api/errors";
import { useIntl } from "../../components/intl";
import * as yup from '../../common/yup';
import Alert from '@material-ui/lab/Alert';


import Box from '@material-ui/core/Box';
import { FormatAlignCenter } from "@material-ui/icons";
import { Email } from '../../legacy_react/src/lib/regex';
import { YupFail } from "../../common/yup";
import { any } from "prop-types";


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
			props.onFailure(lastError);
		}

		if (wasSubmitting && !failed) {
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


	//Error messages
	const { formatMessage } = useIntl();
	const label = formatMessage({ id: 'email', defaultMessage: '* Requiered' })


	//Yup validation
	const validationSchema = yup.object({
		email: yup.string().email().required(),
		password: yup.string().required()
	});

	//Styling 
	const useStyles = makeStyles((theme: Theme) => createStyles({
		textField: {
			'& .MuiTextField-root': {
				margin: theme.spacing(1),
			},
		},
		card: {
			borderRadius: 15,
			boxShadow: 'rgb(192,192,192) 0px 1px 6px, rgba(255, 0, 0, 0.117647) 0px 1px 4px',
			variant: "outlined"
		},
		media: {
			maxWidth: '50ch',
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
					password: ""
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
			}>{({ errors, isValid, touched, handleChange }) => {
				useEffect(() => {
					setIsValid(isValid);
				}, [isValid]);
				return (
					<Form>
						{/* NOTE: if a Button should submit a form, mark it as type="submit". Otherwise pressing Enter won't submit form*/}
						<Grid container
							direction="column"
							alignItems="center"
							justify="center"
						>
							<Card classes={{ root: classes.card }}>
								<Box p={4}>
									<Grid container
										direction="column"
										alignItems="center"
										justify="center"
									>
										<CardMedia component="img"
											src={logo}
											title="Houdini"
											className={classes.media}
										/>
										<CardContent>
											<Typography gutterBottom variant="h5" component="h2">
												Login
											</Typography>
										</CardContent>

										<Box p={1.5}>
											<InputLabel htmlFor="email">Email</InputLabel>
											<TextField
												type="text"
												className={'form-control'}
												id="emal"
												name="email"
												onChange={handleChange}
												InputProps={{
													startAdornment: (
														<InputAdornment position="start">
															<AccountCircle fontSize="small" />
														</InputAdornment>
													),
												}}
											/>
											{errors.email && touched.email ? 
											<Alert severity="error">
												<ErrorMessage name="email" >
													{(errorMessage: any ) => {
														return label
													}}
												</ErrorMessage>
											</Alert>
											: null} 
											
											

										</Box>
										<Box p={1.5}>
											<InputLabel htmlFor="password">Password</InputLabel>
											<TextField
												className={'form-control'}
												id="password"
												name="password"
												type="password"
												onChange={handleChange}
												InputProps={{
													startAdornment: (
														<InputAdornment position="start">
															<LockOpenIcon fontSize="small" />
														</InputAdornment>
													),
												}}
											/>
											{errors.password && touched.password ? 
											<Alert severity="error">
												<ErrorMessage name="password" >
													{(errorMessage: any ) => {
														return label
													}}
												</ErrorMessage>
											</Alert>
											: null} 

										</Box>
										<br />
										<Box>
											<Button
												data-testid="signInButton"
												type="submit"
												variant={'contained'}
												color={'primary'}
											>
												{formatMessage({ id: 'submit' })}
											</Button>
										</Box>
										<br />
										<Link
											component="button"
											variant="body2"
											onClick={() => {
												console.info("I'm a button.");
											}}
										>
											Forgot Password
						</Link>
									</Grid>
								</Box>
							</Card>
						</Grid>

						{componentState === 'submitting' ? "" : <>
							<div data-testid="signInErrorDiv">{failed ? lastError.data.error.map((i) => i).join('; ') : ""}</div>
							<div data-testid="currentUserDiv">{currentUser ? currentUser.id : ""}</div>
						</>
						}
					</Form>
				)
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