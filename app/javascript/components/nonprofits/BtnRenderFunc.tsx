// License: LGPL-3.0-or-later
import React from 'react';
import { RailsContext,  RenderFunctionResult } from 'react-on-rails/node_package/lib/types';
import Btn,{ BtnProps } from './Btn';

export default (props: Record<string, unknown>, _railsContext:RailsContext): RenderFunctionResult => {
	const {innerProps} = props;
	// Note wrap in a function to make this a React function component
	// eslint-disable-next-line react/display-name
	return () => (<Btn {...innerProps as unknown as BtnProps} />);
};
