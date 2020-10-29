// License: LGPL-3.0-or-later
import React, {useEffect, useState} from "react";
import { createStyles, Theme, makeStyles, useTheme } from '@material-ui/core/styles';
import {Formik, Form, Field} from 'formik';
import Button from '@material-ui/core/Button';
import noop from "lodash/noop";
import usePrevious from 'react-use/esm/usePrevious';
import Typography from '@material-ui/core/Typography';
import {spacing}  from '@material-ui/system';
import MuiButton from "@material-ui/core/Button";
import { styled } from "@material-ui/core/styles";
import Grid from '@material-ui/core/Grid';
import { shadows } from '@material-ui/system';


import { CardContent, Link } from '@material-ui/core';
import InputLabel from '@material-ui/core/InputLabel';
import InputAdornment from '@material-ui/core/InputAdornment';
import AccountCircle from '@material-ui/icons/AccountCircle';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import Input from '@material-ui/core/Input';
import Card from '@material-ui/core/Card';
import CardMedia from "@material-ui/core/CardMedia";
import TextField from '@material-ui/core/TextField';
// import logo from './Images/logo.png';


import useCurrentUserAuth from "../../hooks/useCurrentUserAuth";
import { SignInError } from "../../legacy_react/src/lib/api/errors";
import { useIntl } from "../../components/intl";
import * as yup from '../../common/yup';
import { Email } from '../../legacy_react/src/lib/regex';
import { autorun } from "mobx";
import Box from '@material-ui/core/Box';
import { FormatAlignCenter } from "@material-ui/icons";


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

	//Yup validation
	const validationSchema= yup.object({
		email: yup.string().required(),
		password: yup.string()
		  .required()
	});

	//Styling 
	const useStyles = makeStyles((theme: Theme) => createStyles ({
		textField: {
      '& .MuiTextField-root': {
        margin: theme.spacing(1),
        width: '25ch',
			},
		},
		card: {
			borderRadius: 15,
			boxShadow: 'rgb(192,192,192) 0px 1px 6px, rgba(255, 0, 0, 0.117647) 0px 1px 4px',
		 }
		}),
		);
		
	const Button = styled(MuiButton)(spacing);

	const classes = useStyles();
		
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
			<Grid container
				direction="column"
				alignItems="center"
				justify="center"
			>
			
				<Card classes={{ root: classes.card }}
					variant="outlined"
				>
				<Box p={10}>
					<Grid container
						direction="column"
						alignItems="center"
						justify="center"
					>
							
						<CardMedia 
							// className="media"
							// image={logo}
							// title="Houdini"
						/>
						<CardContent>
							<Typography gutterBottom variant="h5" component="h2">
								Login
							</Typography>
						</CardContent>

						<Box p={1.5}>
							<InputLabel htmlFor="input-with-icon-adornment">Email</InputLabel>
								<Input 
									id="input-with-icon-adornment"
									startAdornment={
								<InputAdornment position="start">
								<AccountCircle fontSize="small"/>
								</InputAdornment>
								}
											/> 
						</Box>
						
						<Box p={1.5}>
							<InputLabel htmlFor="input-with-icon-adornment">Password</InputLabel>
								<Input 
									id="input-with-icon-adornment"
									startAdornment={
									<InputAdornment position="start">
										<LockOpenIcon fontSize="small"/>
									</InputAdornment>
								}/>
						</Box>
						<br />
						<Box>
							<Button
								data-testid="signInButton" 
								type="submit"
								variant={'contained'}
								color={'primary'}
							>
							{formatMessage({id: 'submit'})}
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