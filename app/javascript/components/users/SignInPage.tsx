
// License: LGPL-3.0-or-later
import React, {useCallback, useState} from "react";
import Grid from '@material-ui/core/Grid';
import Box from '@material-ui/core/Box';

import SignInComponent from "./SignInComponent";

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
	return (
		<Grid container spacing={3}>
			<Grid item xs={8}>
				<SignInComponent onFailure={onFailure}/>
			</Grid>
			<Grid item xs={4}>
				<Box color="error.main" data-testid="signInPageError">{error ? "Ermahgerd! We had an error!" : ""}</Box>
			</Grid>
		</Grid>
	);
}

export default SignInPage;