// License: LGPL-3.0-or-later
import React, { CSSProperties } from "react";
import Font from '../../legacy/common/brand-fonts';
import utils from '../../legacy/common/utilities';

export interface BtnProps {
	nonprofit: {
		[props: string]: unknown;
		brand_color?: string;
		brand_font?: string;
	};
}

export default function Btn(props: BtnProps): JSX.Element {

	const $logoBlue = '#42B3DF',
		brandColor = props.nonprofit.brand_color || $logoBlue,
		brandFont = (props.nonprofit.brand_font && Font[props.nonprofit.brand_font]) || Font.bitter;

	const donateStyle:CSSProperties = {
		'backgroundColor': brandColor,
		'fontFamily': brandFont.family,
	};

	const isFixed = !!utils.get_param('fixed');

	return (<div className='u-centered' style={
		isFixed ? {
			paddingTop: '5px',
		} : {}
	}>
		<p className={`branded-donate-button ${isFixed ? "is-fixed" : ''}`} style={donateStyle}>Donate</p>
	</div>);
}
