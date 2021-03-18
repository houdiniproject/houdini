// License: LGPL-3.0-or-later
import React, { useState } from "react";
import Grid from '@material-ui/core/Grid';
import Box from '@material-ui/core/Box';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import logo from './Images/HoudiniLogo.png';
import CardMedia from '@material-ui/core/CardMedia';
import { useIntl } from "../../components/intl";
import SignInComponent from './SignInComponent';
import { Paper } from "@material-ui/core";
import LockIcon from '@material-ui/icons/LockOutlined';
import Avatar from '@material-ui/core/Avatar';
import { ErrorBoundary } from 'react-error-boundary';
import userRoutes from '../../routes/users';
import staticRoutes from '../../routes/static';
import useHoster from '../../hooks/useHoster';
import Alert from '@material-ui/lab/Alert';
import Backdrop from '@material-ui/core/Backdrop';
import CircularProgress from '@material-ui/core/CircularProgress';
import { rgb } from "color";
import Fade from '@material-ui/core/Fade';

interface SignInPageProps {
	redirectUrl: string;
}

//Error Boundary
export const Fallback = (): React.ReactElement => {
	const { formatMessage } = useIntl();
	const errorBoundaryLabel = formatMessage({ id: 'login.errors.error_boundary' });
	return (
		<Box m={3} display="flex" justifyContent="center" alignItems="center" textAlign="center">
			<Alert severity="error">{errorBoundaryLabel}</Alert>
		</Box>
	);
};

function SignInPage(props: SignInPageProps): JSX.Element {
	const [SignInPageState, setSignInPageState] = useState<'ready' | 'submitting' | 'success'>('ready');
	const [open, setOpen] = React.useState(false);

	const handleClose = () => {
		setOpen(false);
		open;
	};

	function onSuccess() {
		setSignInPageState("success");
		window.location.assign(props.redirectUrl);
		SignInPageState;
	}

	function onReady() {
		setSignInPageState("ready");
		document.body.setAttribute('style', '');
	}
	function onSubmitting() {
		setSignInPageState("submitting");
		document.body.setAttribute('style', 'overflow:hidden');
	}

	//Styling of component
	const useStyles = makeStyles((theme: Theme) =>
		createStyles({
			menuButton: {
				marginRight: theme.spacing(2),
			},
			title: {
				flexGrow: 1,
			},
			logo: {
				alignItems: 'center',
				width: 100,
				height: 75,
				justifyContent: "center",
			},
			text: {
				display: "flex",
				justifyContent: "center",
				alignItems: "center",
				textAlign: "center",
			},
			media: {
				maxWidth: 250,
			},
			lowercase: {
				textTransform: "none",
			},
			buttonProgress: {
				position: 'absolute',
				color: "inherit",
				transitionDuration: '1000',
			},
			avatar: {
				marginTop: theme.spacing(3),
				backgroundColor: "#3f51b5",
			},
			appbar: {
				backgroundColor: theme.palette.action.hover,
			},
			backdrop: {
				zIndex: theme.zIndex.drawer + 1,
				background: rgb(255, 255, 255, 0.5).toString(),
			},
			responsive: {
				[theme.breakpoints.down('sm')]: {
					width: "100%",
					marginTop: 45,
					marginBottom: 45,
				},
				[theme.breakpoints.up('lg')]: {
					margin: 75,
				},
				[theme.breakpoints.down('md')]: {
					marginTop: 45,
					marginBottom: 45,
				},
			},
			paper: {
				margin: `${theme.spacing(1)}px auto`,
				padding: theme.spacing(2),
				borderRadius: 15,
				minHeight: 500,
			},
		}),
	);

	//Setting up error messages
	const classes = useStyles();
	const { hoster } = useHoster();
	const { formatMessage } = useIntl();
	const loginHeaderLabel = formatMessage({ id: 'login.enter_login_information' });
	const forgotPasswordlabel = formatMessage({ id: 'login.forgot_password' });
	const terms = formatMessage({ id: 'footer.terms_and_privacy' });
	const getStartedLabel = formatMessage({ id: 'login.get_started' });
	const successLabel = formatMessage({ id: 'login.success' });


	return <ErrorBoundary FallbackComponent={Fallback}>
		<Grid container spacing={0}>
			<Grid item xs={12}>
				<AppBar position="static" className={classes.appbar} elevation={1}>
					<Toolbar >
						<Grid>
							<CardMedia
								className={classes.media}
								component="img"
								src={logo}
								title="Houdini"
							/>
						</Grid>
					</Toolbar>
				</AppBar>
			</Grid>
			<Grid container justify="center">
				<Box className={classes.responsive} width="45%" justifyContent="center" alignItems="center">
					<Paper className={classes.paper} elevation={6}>
						<Typography variant="h5" component="h2">
							<Box display="flex" justifyContent="center" alignItems="center" >
								<Avatar className={classes.avatar}>
									<LockIcon />
								</Avatar>
							</Box>
							<Box m={3} display="flex" justifyContent="center" alignItems="center" textAlign="center"
							>
								{loginHeaderLabel}
							</Box>
						</Typography>
						<div data-testid="SignInComponent">
							<SignInComponent
								onSuccess={onSuccess}
								onSubmitting={onSubmitting}
								onFailure={onReady}
							/>
						</div>
						{/* Links: To add more links add another box and replace the label, set margin to -1.5 to reduce
              space between links */}
						<Box m={1} display="flex" justifyContent="center">
							<Link href={userRoutes.newUserPassword.path()} data-testid="passwordTest"> {forgotPasswordlabel} </Link>
						</Box>
						<Box m={1} display="flex" justifyContent="center">
							<Link href={userRoutes.newUserPassword.path()} data-testid="getStartedTest" > {getStartedLabel} </Link>
						</Box>
						<Box color="error.main" data-testid="signInPageError"></Box>
						<div data-testid='backdropTest' >
							<Fade in={SignInPageState === 'submitting'}>
								<Backdrop className={classes.backdrop} open={true} onClick={handleClose}>
									<CircularProgress size={50} className={classes.buttonProgress} />
								</Backdrop>
							</Fade>
							<Fade in={SignInPageState === 'success'}>
								<Backdrop className={classes.backdrop} open={true} onClick={handleClose} >
									<Alert severity="success">{successLabel}</Alert>
								</Backdrop>
							</Fade>
						</div>
					</Paper>
				</Box>
			</Grid>
			{/* Footer */}
			<Grid item xs={12} >
				<AppBar position="static" className={classes.appbar} elevation={1}>
					<Toolbar>
						<Box color="text.primary">
							<Grid container>
								<Box m={1} data-testid="hosterTest">
									{hoster ? (<> ©{hoster.legalName}</>) : ""}
								</Box>
								{/* Link
                    To add more links add another box and replace the label, set margin to -1.5 to reduce
                    space between links */}
								<Box m={1} color="text.primary">
									<Link data-testid="termsTest" href={staticRoutes.termsAndPrivacy.path()}> {terms} </Link>
								</Box>
								{/* End of link */}
							</Grid>
						</Box>
					</Toolbar>
				</AppBar>
			</Grid>
		</Grid>
	</ErrorBoundary>;
}

export default SignInPage;