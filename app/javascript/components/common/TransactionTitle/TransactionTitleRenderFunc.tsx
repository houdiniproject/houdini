// License: LGPL-3.0-or-later
import React from 'react';
import { RailsContext,  RenderFunctionResult } from 'react-on-rails/node_package/lib/types';
import TransactionTitle, {TransactionTitleProps} from '.';


export default (props: Record<string, unknown>, _railsContext:RailsContext): RenderFunctionResult => {
	const {innerProps} = props;
	// Note wrap in a function to make this a React function component
	// eslint-disable-next-line react/display-name
	return () => (
		<TransactionTitle {...innerProps as unknown as TransactionTitleProps}/>
	);
};
