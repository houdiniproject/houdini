// License: LGPL-3.0-or-later
import React from 'react';

export default function Section(props: React.PropsWithChildren<unknown>): JSX.Element {
	return (
		<section className='sideNav-section'>
			{props.children}
		</section>
	);
}

