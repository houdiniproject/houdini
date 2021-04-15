// License: LGPL-3.0-or-later
import * as React from 'react';
import { createMuiTheme } from '@material-ui/core/styles';
import { ThemeProvider } from 'react-jss';
import AnimatedCheckmark, {AnimatedCheckmarkProps} from './AnimatedCheckmark';

export default {
	title: 'users/AnimatedCheckmark',
	component: AnimatedCheckmark,
};

type TemplateArgs = AnimatedCheckmarkProps;

const theme = createMuiTheme();
const CheckmarkTemplate = (args:TemplateArgs) => {

	return <ThemeProvider theme={theme}>
		<AnimatedCheckmark
			{...args}
			key={Math.random() /* so it reloads everytime props change */}></AnimatedCheckmark>
	</ThemeProvider>;
};

export const Checkmark = CheckmarkTemplate.bind({});
Checkmark.args = {
};



