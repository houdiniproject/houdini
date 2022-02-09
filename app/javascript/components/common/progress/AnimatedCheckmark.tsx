// License: LGPL-3.0-or-later
// from: https://github.com/davidwilson3/react-typescript-checkmark/blob/1de3e0362965602d4345868f1f876aa54a96d5b6/src/checkmark.tsx
import React from 'react';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';

interface StyledProps {
	animationDuration: number;
	backgroundColor: string;
	checkColor: string;
	checkThickness: number;
	explosion: number;
	height: number;
  width: number;
}

const useStyles = (makeStyles((theme:Theme) =>
	createStyles({
		root: {
			display: "block",
			marginLeft: "auto",
			marginRight: "auto",
			borderRadius: "50%",
			width: (props:StyledProps) => props.width,
			height: (props:StyledProps) => props.height,
			stroke: (props:StyledProps) => props.checkColor,
			strokeWidth: (props:StyledProps) => props.checkThickness,
			strokeMiterlimit: 10,
			animation: (props:StyledProps) => `$fill ${props.animationDuration * 0.66}s ease-in-out 0.4s
        forwards,
      $scale 0.3s ease-in-out 0.9s both`,
		},
		circle: {
			strokeDasharray: 166,
			strokeDashoffset: 166,
			strokeWidth: (props:StyledProps) => props.checkThickness,
			strokeMiterlimit: 10,
			stroke: (props:StyledProps) => props.backgroundColor || theme.palette.success.main,
			fill: "none",
			animation: (props:StyledProps) => `$stroke-keyframe ${props.animationDuration}s
      cubic-bezier(0.65, 0, 0.45, 1) forwards`,
		},
		checkmark: {
			transformOrigin: "50% 50%",
			strokeDasharray: 48,
			strokeDashoffset: 48,
			animation: (props:StyledProps) => `$stroke-keyframe ${props.animationDuration * 0.5}s
      cubic-bezier(0.65, 0, 0.45, 1) 0.8s forwards`,
		},

		"@keyframes scale": {
			"0%": {},
			"100%": {
				transform: "none",
			},
			"50%": {
				transform: (props:StyledProps) => `scale3d(${props.explosion}, ${props.explosion}, 1)`,
			},
		},
		"@keyframes fill": {
			"100%": {
				boxShadow: (props:StyledProps) =>  `inset 0 0 0 100vh ${props.backgroundColor || theme.palette.success.main}`,
			},
		},
		"@keyframes stroke-keyframe": {
			"100%": {
				/* this is needed because makeStyles function has bugs (https://github.com/mui-org/material-ui/issues/15511) */
				strokeDashoffset:() => 0,
			},
		},
	})
));


/**
 * The different preset checkmark sizes. Measured in pixels
 */
export const sizes = {
	xs: 12,
	sm: 16,
	md: 24,
	lg: 52,
	xl: 72,
	xxl: 96,
};

export type Sizes = keyof typeof sizes;

export interface AnimatedCheckmarkProps {
	/**
	 * Duration of the checkmark animation in milliseconds
	 */
	animationDuration: number;
	/** A string for describing what the component means in screen readers*/
	ariaLabel: string;

	/** Color in hex of the circle and background of component
	 * 	Defaults to `theme.palette.success.main`
	*/
	backgroundColor?: string;
	/**
	 * Color in hex of checkmark in the middle of the component
	 * Defaults to white (#000)
	 */
	checkColor?: string;
	/**
	 * The stroke width of the checkmark. Defaults to 5.
	 */
	checkThickness: number;

	/**
	 * How much the circle temporarily expands to on success. 1 means no expansion, 1.1 means 10% expansion, etc.
	 * Defaults to 1.1
	*/
	explosion: number;
	/**
	 * The role for accessibility purposes.
	 * Defaults to 'alert'.
	 */
	role?: string;
	/**
	 * The height and width in pixels of the component. Accepts a size string (listed in `sizes`) or a number
	 *
	 * Defaults to 'lg' which is 52 pixels
	 */
  size: Sizes | number;
	/**
	 * Whether the component should be visible in the document.
	 */
	visible: boolean;
}

function AnimatedCheckmark(props: AnimatedCheckmarkProps): JSX.Element {
	const selectedSize = typeof props.size === 'number' ? props.size : sizes[props.size];


	const classes = useStyles({
		backgroundColor: props.backgroundColor!,
		checkColor: props.checkColor!,
		checkThickness: props.checkThickness,
		animationDuration: props.animationDuration,
		explosion: props.explosion,
		width: selectedSize,
		height: selectedSize,
	});
	if (!props.visible) return <></>;
	return (
		<svg
			data-testid="CheckmarkTest"
			className={classes.root}
			xmlns='http://www.w3.org/2000/svg'
			viewBox='0 0 52 52' role={props.role} aria-label={props.ariaLabel}
		>
			<circle className={classes.circle} cx='26' cy='26' r='25' fill='none' />
			<path className={classes.checkmark} fill='none' d='M14.1 27.2l7.1 7.2 16.7-16.8' />
		</svg>
	);
}

AnimatedCheckmark.defaultProps = {
	size: 'lg',
	visible: true,
	checkColor: '#FFF',
	checkThickness: 5,
	animationDuration: 0.6,
	explosion: 1.1,
	role: 'alert',
};

export default AnimatedCheckmark;