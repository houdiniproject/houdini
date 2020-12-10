import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import Box from '@material-ui/core/Box';
import DoneIcon from '@material-ui/icons/Done';
import FiberManualRecordSharpIcon from '@material-ui/icons/FiberManualRecordSharp';

const useStyles = makeStyles(theme => ({
	root: {
		fontSize: 100,
		color: '#4caf50',
		animation: `$myEffectRoot 300ms ${theme.transitions.easing.easeIn}`,
	},
	doneIcon: {
		fontSize: 60,
		color: '#fff',
		position: 'absolute',
		animation: `$myEffectDoneIcon 300ms ${theme.transitions.easing.easeIn}`,
	},
	"@keyframes myEffectRoot": {
		"0%": {
			opacity: 0,
		},
		"100%": {
			opacity: 1,
		},
		"50%": {
			transform: 'explosion',
		},
	},
	"@keyframes myEffectDoneIcon": {
		"0%": {
			opacity: 0,
		},
		"100%": {
			opacity: 4,
		},
	},
}));

function AnimatedCheckmark(): JSX.Element  {
	const classes = useStyles();

	return (
		<>
			<Box m={13} display="flex" justifyContent="center" alignItems="center">
				<DoneIcon className={classes.doneIcon}/>
				<FiberManualRecordSharpIcon className={classes.root}/>
			</Box>
		</>
	);
}

export default AnimatedCheckmark;