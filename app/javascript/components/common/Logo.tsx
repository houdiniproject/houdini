// License: LGPL-3.0-or-later
// from app/views/common/_logo.html.erb

import React from 'react';


export interface LogoProps {
	alt: string;
	logoUrl: string;
}

export default function Logo(props: React.PropsWithChildren<LogoProps>): JSX.Element {
	return (
		<span className='commitchangeLogo'>
			<img src={props.logoUrl} alt={props.alt} />

		</span>);

}
