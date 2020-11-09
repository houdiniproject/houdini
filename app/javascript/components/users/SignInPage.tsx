
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
        width: 150,
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
        height: 75,
      },
      card: {
      
        
      },
      paper: {
        maxWidth: 325,
        margin: `${theme.spacing(1)}px auto`,
        padding: theme.spacing(2),
        borderRadius: 15,
      },
		}),
		);

	
  const classes = useStyles();


	return (
		<Grid container spacing={0}>
			<Grid item xs={12}>
      <div className={classes.root}>
            <AppBar position="static" color="primary">
            <Toolbar >
              <Box p={3}>
                <Typography 
                  variant="h5"
                  className={classes.title}
                  >
                  <Box letterSpacing={2} fontWeight="fontWeightBold">
                    SIGN IN PAGE
                  </Box>
                </Typography>
              </Box>
            </Toolbar>
            </AppBar>
          </div>
			</Grid>
     <Grid container spacing={0}>
       <Grid item xs={12}>
        <CardMedia
          className={classes.media}
          component="img"
          src={logo}
          title="Houdini"
                      
        />
      </Grid>
      <Grid container
            xs={6} 
            justify="center">

          {/* <Paper className={classes.paper} elevation={6}> */}
            <Grid item xs={6}>
              <Typography variant="h4" className={classes.text} >
                <Box letterSpacing={3} fontWeight="fontWeightBold " >
                  Welcome! 
                </Box>
              </Typography>
            </Grid>
            <Typography className={classes.text} >
              <Box>
              Please Login to countinue or select the following options below.
              </Box>
            </Typography>
              <CardActions>
                    <Button size="large" color="primary">
                      Forgot Password
                    </Button>
                    <Button size="large" color="primary">
                      Get Started
                    </Button>
              </CardActions>
          {/* </Paper> */}
        </Grid>

        <Grid container xs={5} justify="flex-start">
          <SignInComponent onFailure={onFailure}/>
          <Box color="error.main" data-testid="signInPageError">{error ? "Ermahgerd! We had an error!" : ""}</Box>
        </Grid>
      </Grid>
      <Grid item xs={12} >
              <AppBar position="static">
              <Toolbar>
              <Typography className={classes.link} >
                <CopyrightIcon fontSize="small" className={classes.wrapIcon} />
                  {'2020 Houdini Project '}
                <Link href="" color="inherit">
                  {'Terms & Privacy'}
                </Link>
                </Typography>
              </Toolbar>
              </AppBar>
        
        </Grid>
		</Grid>
			
		
		
	);
	
	
	
}


export default SignInPage;