// License: LGPL-3.0-or-later
import React from 'react';
import { RailsContext,  RenderFunctionResult } from 'react-on-rails/node_package/lib/types';
import PageWrapper, { PageContextInput } from './PageWrapper';
import SideNav from './SideNav';


export default (props: Record<string, unknown>, railsContext:RailsContext): RenderFunctionResult => {
	const {innerProps, ...other} = props;
	// Note wrap in a function to make this a React function component
	// eslint-disable-next-line react/display-name
	return () => (<PageWrapper {...other as unknown as PageContextInput} railsContext={railsContext}>
		<SideNav {...innerProps as unknown as any}/>
	</PageWrapper>
	);
};
