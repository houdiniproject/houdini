// License: LGPL-3.0-or-later
import React, {PropsWithChildren, useEffect, useState} from 'react';
import { HosterContext } from '../../hooks/useHoster';

interface MockHosterProviderProps {
	/**
	 * The legal name of the hoster. Defaults to "HoudiniCo LLC"
	 *
	 * @type {string}
	 * @memberof MockHosterProviderProps
	 */
	legalName:string;
}

export default function MockHosterProvider(props:PropsWithChildren<MockHosterProviderProps>) : JSX.Element {
	const hosterFromProps = {legalName:props.legalName};
	const [hoster, setHoster] = useState(hosterFromProps);

	useEffect(() => {
		setHoster({legalName: props.legalName});
	}, [props.legalName]);

	const values = {hoster};
	return (<HosterContext.Provider value={values}>
		{props.children}
	</HosterContext.Provider>);
}

MockHosterProvider.defaultProps = {
	legalName: "HoudiniCo LLC",
};