// License: LGPL-3.0-or-later

import { makeStyles } from "@material-ui/core/styles";
import colors from '../../../../legacy_react/src/lib/nonprofitBranding';


function cssGradient(dir: string, to: string, from: string) {
	return `linear-gradient(${dir}, ${to}, ${from})`;
}

interface MakeStylesProps {
	nonprofitColor: string;
}

const useStyles = makeStyles({
	'@global': {
		'.badge': {
			display: 'inline-block',
			minWidth: '10px',
			'padding': '3px 7px',
			'fontSize': '11px',
			'fontWeight': 'bold',
			'color': '#fff',
			'lineHeight': '1',
			'verticalAlign': 'middle',
			'whiteSpace': 'nowrap',
			'textAlign': 'center',
			'backgroundColor': '#9c9c9c',
			'borderRadius': '10px',
		},
		'.badge:empty': {
			display: 'none',
		},
		'button .badge': {
			'position': 'relative',
			'top': '-1px',
		},
		'.wizard-steps div.is-selected, .wizard-steps button.is-selected': {
			backgroundColor: (props: MakeStylesProps) => `${colors(props.nonprofitColor).lighter} !important`,
		},
		'wizard-steps .button.white': {
			'color': '#494949',
		},
		'.wizard-steps a:not(.button--small), .ff-wizard-index-label.ff-wizard-index-label--accessible, .wizard-index-label.is-accessible': {
			color: (props: MakeStylesProps) => `${colors(props.nonprofitColor).dark} !important`,
		},
		'wizard-steps input.is-selected': {
			borderColor: (props: MakeStylesProps) => `${colors(props.nonprofitColor).light} !important`,
		},
		'.wizard-steps button:not(.white):not([disabled])': {
			backgroundColor: (props: MakeStylesProps) => `${colors(props.nonprofitColor).dark} !important`,
		},
		'.wizard-steps .highlight': {
			backgroundColor: (props: MakeStylesProps) => `${colors(props.nonprofitColor).lightest} !important`,
		},

		'.wizard-steps label, .wizard-steps th': {
			color: '#636363',
		},
		".wizard-steps input[type='radio']:checked + label:before": {
			backgroundColor: (props: MakeStylesProps) => `${colors(props.nonprofitColor).base} !important`,
		},
		".wizard-steps input[type='checkbox'] + label:before": {
			color: (props: MakeStylesProps) => `${colors(props.nonprofitColor).base} !important`,
		},
		".ff-wizard-index-label.ff-wizard-index-label--current, .wizard-index-label.is-current": {
			backgroundImage: (props: MakeStylesProps) => cssGradient('left', '#fbfbfb', colors(props.nonprofitColor).light),
		},
	},
});

export function useBrandedWizard(nonprofitColor: string): Record<"@global", string> {
	return useStyles({ nonprofitColor });
}
