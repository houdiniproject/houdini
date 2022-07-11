// License: LGPL-3.0-or-later
// from app/views/common/_logo.html.erb

import React from 'react';


export interface LogoProps {
	alt: string;
	url: string;
}

export default function Logo(props: LogoProps): JSX.Element {
	return (
		<span className='commitchangeLogo'>
			<img src={props.url} alt={props.alt} />

		</span>);

}
