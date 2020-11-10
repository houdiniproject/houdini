// License: LGPL-3.0-or-later
import React, {useCallback, useState} from "react";
import Grid from '@material-ui/core/Grid';
import Box from '@material-ui/core/Box';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import CopyrightIcon from '@material-ui/icons/Copyright';
import logo from './Images/HoudiniLogo.png';
import CardMedia from '@material-ui/core/CardMedia';
import grey from '@material-ui/core/colors/grey';
import blue from '@material-ui/core/colors/blue';
import useYup from '../../hooks/useYup';
import { useIntl } from "../../components/intl";
import SignInComponent from "./SignInComponent";
import { Paper } from "@material-ui/core";
import LockIcon from '@material-ui/icons/LockOutlined';
import Avatar from '@material-ui/core/Avatar';
import {ErrorBoundary} from 'react-error-boundary';

// NOTE: You should remove this line and next when you start adding properties to SignInComponentProps
// eslint-disable-next-line @typescript-eslint/no-empty-interface
interface SignInPageProps {
}

// NOTE: Remove this line and next once you start using the props argument
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function SignInPage(_props:SignInPageProps) : JSX.Element {
	const [error, setError] = useState(false);
	const onFailure = useCallback(() => {
		setError(true);
	}, [setError]);


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
      link: {
        '& > * + *': {
          marginLeft: theme.spacing(2),
          color: "#212121",
        },
      },
      wrapIcon: {
        verticalAlign: 'middle',
        display: 'inline-flex',
        color: "#212121"
       },
       logo:{
        alignItems:'center',
        width: 100,
        height: 75,
        justifyContent:"center",   
       },
       text:{
        display:"flex",
        justifyContent:"center",
        alignItems:"center",
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
        background: grey[200],
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
      },
      paper: {
        margin: `${theme.spacing(1)}px auto`,
        padding: theme.spacing(2),
        borderRadius: 15,
      },
		}),
		);

  //Error boundary
  class ErrorBoundary extends React.Component {
    constructor(props) {
      super(props);
    }
    state = {
      errorMessage: 'Something went wrong. Reload the page'
    }
    static getDerivedStateFromError(error) {
      // Update state so the next render will show the fallback UI.
      return { hasError: true };
    }
    componentDidCatch(error, errorInfo) {
      // You can also log the error to an error reporting service
      this.logErrorToServices(error, errorInfo);
    }
    logErrorToServices = console.log
    render() {
      if (this.state.errorMessage) {
        return (
          <p>
            {this.state.errorMessage}
          </p>
        )
      }
      return this.props.children; 
    }
  }

	//Setting up error messages
  const classes = useStyles();
  const { formatMessage } = useIntl();
	const yup = useYup();
  const loginHeaderLabel = formatMessage({id: 'login.header'});
  const forgotPasswordlabel = formatMessage({id: 'login.forgot_password'});
  const copyright = formatMessage({id: 'footer.copyright'});
  const terms = formatMessage({id: 'footer.terms_and_privacy'});
  const getStartedLabel = formatMessage({id: 'login.get_started'});

	return (
		<Grid container spacing={0}>
			<Grid item xs={12}>
      <div className={classes.root}>
            <AppBar position="static" className={classes.appbar}>
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
        <Box   className={classes.responsive} width="45%" justifyContent="center" alignItems="center">
        <Paper className={classes.paper} elevation={6}>
							<Typography gutterBottom variant="h5" component="h2">
              <Box display="flex" justifyContent="center" alignItems="center" >
              <Avatar className={classes.avatar}>
                <LockIcon />
              </Avatar>
              </Box>
              <Box p={0} 
                  display="flex" justifyContent="center" 
                  alignItems="center" 
                  >
								<p>{loginHeaderLabel}</p>
                </Box> 
							</Typography>
                <ErrorBoundary>
                  <SignInComponent />
                </ErrorBoundary>          
            {/* Links: To add more links add another box and replace the label, set margin to -1.5 to reduce 
            space between links */}
            <Box display="flex" justifyContent="center">
              <Link
                      component="button"
                      variant="body2"
                      onClick={() => {
                        console.info("I'm forgotPassword button.");
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
                        console.info("I'm getStarted button.");
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
      <Grid item xs={12} >
              <AppBar position="static" className={classes.appbar}>
              <Toolbar>
              <Typography className={classes.link} >
                <CopyrightIcon fontSize="small" className={classes.wrapIcon} />
                <Link href="" > 
                {copyright}
                </Link>
                <Link href="" >
                  {terms}
                </Link>
              </Typography>
              </Toolbar>
              </AppBar>
        
        </Grid>
		</Grid>
	);
}

export default SignInPage;