// License: LGPL-3.0-or-later
import React, { useCallback, useEffect, useState } from "react";
import Grid from '@material-ui/core/Grid';
import Box from '@material-ui/core/Box';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import logo from './Images/HoudiniLogo.png';
import CardMedia from '@material-ui/core/CardMedia';
import useYup from '../../hooks/useYup';
import { useIntl } from "../../components/intl";
import SignInComponent from './SignInComponent';
import { Paper } from "@material-ui/core";
import LockIcon from '@material-ui/icons/LockOutlined';
import Avatar from '@material-ui/core/Avatar';
import {ErrorBoundary, useErrorHandler} from 'react-error-boundary';
import routes from '../../routes';
import UseHoster from '../../hooks/useHoster';

// NOTE: You should remove this line and next when you start adding properties to SignInComponentProps
// eslint-disable-next-line @typescript-eslint/no-empty-interface
interface SignInPageProps {
  redirectUrl: string;
  onSubmitting?: () => void;
  onSuccess?: () => void;
}

//Error Boundary
function Fallback() {
  const { formatMessage } = useIntl();
  const errorBoundaryLabel = formatMessage({ id: 'login.errors.error_boundary' });
  return <div>{errorBoundaryLabel}</div>
}

// NOTE: Remove this line and next once you start using the props argument
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function SignInPage(props: SignInPageProps): JSX.Element {
  const [SignInPageState, setSignInPageState] = useState<'ready' | 'submitting' | 'success'>('ready');
  const [error, setError] = useState(false);
  const onFailure = useCallback(() => {
    setError(true);
  }, [setError]);

  function onSuccess(){
      window.location.assign(props.redirectUrl)
    }
  
  //Styling of component
  const useStyles = makeStyles((theme: Theme) =>
    createStyles({
      root: {
        flexGrow: 1,
      },
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
      avatar: {
        marginTop: theme.spacing(3),
        backgroundColor: "#3f51b5",
      },
      appbar: {
        backgroundColor: theme.palette.action.hover,
      },
      responsive: {
        [theme.breakpoints.down('sm')]: {
          width: "100%",
          marginTop: 45,
          marginBottom: 45
        },
        [theme.breakpoints.up('lg')]: {
          margin: 75,
        },
        [theme.breakpoints.down('md')]: {
          marginTop: 45,
          marginBottom: 45
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
  const { formatMessage } = useIntl();
  const yup = useYup();
  const loginHeaderLabel = formatMessage({ id: 'login.enter_login_information' });
  const forgotPasswordlabel = formatMessage({ id: 'login.forgot_password' });
  const copyright = formatMessage({ id: 'footer.copyright' });
  const terms = formatMessage({ id: 'footer.terms_and_privacy' });
  const getStartedLabel = formatMessage({ id: 'login.get_started' });

  return <ErrorBoundary FallbackComponent={Fallback}> 
      <Grid container spacing={0}>
        <Grid item xs={12}>
          <div className={classes.root}>
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
          </div>
        </Grid>
        <Grid container spacing={0}>
          <Grid container xs={12} justify="center">
            <Box className={classes.responsive} width="45%" justifyContent="center" alignItems="center">
              <Paper className={classes.paper} elevation={6}>
                <Typography variant="h5" component="h2">
                  <Box display="flex" justifyContent="center" alignItems="center" >
                    <Avatar className={classes.avatar}>
                      <LockIcon />
                    </Avatar>
                  </Box>
                  <Box display="flex" justifyContent="center" alignItems="center" textAlign="center"
                  >
                    <p>{loginHeaderLabel}</p>
                  </Box> 
                </Typography>
                <SignInComponent onSuccess={onSuccess}/>
                {/* Links: To add more links add another box and replace the label, set margin to -1.5 to reduce 
              space between links */}
                <Box display="flex" justifyContent="center">
                  <Link href= {routes.new_user_password_path()}
                    onClick={() => {
                      console.info("I'm forgot Password link.");
                    }}
                  >
                    <p>{forgotPasswordlabel}</p>
                  </Link>
                </Box>
                <Box m={-1.5} display="flex" justifyContent="center">
                  <Link
                    component="button"
                    variant="body2"
                    onClick={() => {
                      console.info("I'm getStarted link.");
                    }}
                  >
                    <p>{getStartedLabel}</p>
                  </Link>
                </Box>
                <Box color="error.main" data-testid="signInPageError">{error ? "Ermahgerd! We had an error!" : ""}</Box>
              </Paper>
            </Box> 
          </Grid>
        </Grid>
        {/* Footer */}
        <Grid item xs={12} >
          <AppBar position="static" className={classes.appbar} elevation={1}>
            <Toolbar>
              <Box color="text.primary">
                  <Grid container xs={12}>
                    <Box m={1}>
                      ©{UseHoster}
                    </Box>
                    {/* Link
                    To add more links add another box and replace the label, set margin to -1.5 to reduce 
                    space between links */}
                    <Box m={1} color="text.primary">
                      <Link href={routes.static_terms_and_privacy_path()}>
                        {terms}
                      </Link>
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