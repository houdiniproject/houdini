import React from 'react';
import noop from "lodash/noop";
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';

interface StyledProps {
  backgroundColor: string;
  checkColor: string;
  checkThickness: number;
  animationDuration: number;
  explosion: number;
  width: number;
  height: number;
}

const useStyles = makeStyles((theme: Theme) =>
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
			animation: (props:StyledProps) => `fill ${props.animationDuration * 0.66}s ease-in-out 0.4s
        forwards,
      scale 0.3s ease-in-out 0.9s both`,
		},
		circle: {
			strokeDasharray: 166,
			strokeDashoffset: 166,
			strokeWidth: (props:StyledProps) => props.checkThickness,
			strokeMiterlimit: 10,
			stroke: (props:StyledProps) => props.backgroundColor,
			fill: "none",
			animation: (props:StyledProps) => `stroke ${props.animationDuration}s
      cubic-bezier(0.65, 0, 0.45, 1) forwards`,
		},
		checkmark: {
			transformOrigin: "50% 50%",
			strokeDasharray: 48,
			strokeDashoffset: 48,
			animation: (props:StyledProps) => `stroke ${props.animationDuration * 0.5}s
      cubic-bezier(0.65, 0, 0.45, 1) 0.8s forwards`,
		},
		"@keyframes stroke": {
			"100%": {
				strokeDashoffset: 0,
			},
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
				boxShadow: (props:StyledProps) =>  `inset 0 0 0 100vh ${props.backgroundColor}`,
			},
		},
	})
);

export const sizes = {
	xs: 12,
	sm: 16,
	md: 24,
	lg: 52,
	xl: 72,
	xxl: 96,
};

export type Sizes = keyof typeof sizes;

interface Props extends Partial<StyledProps> {
  size?: Sizes | number;
  visible?: boolean;
  className?: string;
}

const AnimatedCheckmark = ({
	size = 'lg',
	visible = true,
	backgroundColor = '#7ac142',
	checkColor = '#FFF',
	checkThickness = 5,
	animationDuration = 0.6,
	explosion = 1.1,
}: Props) => {
	const selectedSize = typeof size === 'number' ? size : sizes[size];

	if (!visible) return <></>;

	const classes = useStyles({
		backgroundColor: backgroundColor,
		checkColor: checkColor,
		checkThickness: checkThickness,
		animationDuration: animationDuration,
		explosion: explosion,
		width: selectedSize,
		height: selectedSize,
	});

	return (
		<svg
			className={classes.root}
			xmlns='http://www.w3.org/2000/svg'
			viewBox='0 0 52 52'
		>
			<circle className={classes.circle} cx='26' cy='26' r='25' fill='none' />
			<path className={classes.checkmark} fill='none' d='M14.1 27.2l7.1 7.2 16.7-16.8' />
		</svg>
	);
};

AnimatedCheckmark.defaultProps = {
	// default onFailure to noop so you don't have to check whether onFailure is
	// set inside the component before calling it
	backgroundColor: noop,
	checkColor: noop,
	checkThickness: noop,
	animationDuration: noop,
	explosion: noop,
	width: noop,
	height: noop,
};

export default AnimatedCheckmark;