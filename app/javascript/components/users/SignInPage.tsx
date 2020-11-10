
// License: LGPL-3.0-or-later
import React, {useCallback, useState} from "react";
import Grid from '@material-ui/core/Grid';
import Box from '@material-ui/core/Box';

import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import Button from '@material-ui/core/Button';
import Link from '@material-ui/core/Link';
import CopyrightIcon from '@material-ui/icons/Copyright';
import logo from './Images/HoudiniLogo.png';
import Card from '@material-ui/core/Card';
import CardActionArea from '@material-ui/core/CardActionArea';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';
import grey from '@material-ui/core/colors/grey';


import useYup from '../../hooks/useYup';
import { useIntl } from "../../components/intl";
import SignInComponent from "./SignInComponent";
import { Paper } from "@material-ui/core";

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
        },
      },
      wrapIcon: {
        verticalAlign: 'middle',
        display: 'inline-flex'
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
    uppercase: {
      textTransform: "uppercase",
  },
    appbar: {
      background: grey[400],
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

	
  const classes = useStyles();
  const { formatMessage } = useIntl();
	const yup = useYup();
  const loginHeaderLabel = formatMessage({id: 'login.header'});
  const forgotPasswordlabel = formatMessage({id: 'login.forgot_password'});
  const copyright = formatMessage({id: 'footer.copyright'});
  const terms = formatMessage({id: 'footer.terms_and_privacy'});



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
              <Box p={1} 
                  className={classes.uppercase} 
                  display="flex" justifyContent="center" 
                  alignItems="center" 
                  fontWeight="fontWeightBold"
                  letterSpacing={1}
                  >

								<p>{loginHeaderLabel}</p>
                </Box> 
							</Typography>
						    
            <SignInComponent />
            <Box display="flex" justifyContent="center">
              <Button className={classes.lowercase} size="medium" color="primary">
                <p>{forgotPasswordlabel}</p>
              </Button>
              <Button className={classes.lowercase} size="medium" color="primary">
                <p>Get Started</p>
              </Button>
              </Box>
                    {/* <Button className={classes.lowercase} size="small" color="primary">
                      Exmaple
                    </Button>
                    <Grid container xs={12} justify="center">
                    <Button className={classes.lowercase} size="small" color="primary">
                      Example
                    </Button>
                    </Grid> */}
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
                  {copyright}
                <Link href="" color="inherit">
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