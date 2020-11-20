/* eslint-disable jest/no-disabled-tests */

// License: LGPL-3.0-or-later

import React, { useEffect } from 'react';
import { render, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import MockCurrentUserProvider from './MockCurrentUserProvider';
import useCurrentUser, { SetCurrentUserReturnType } from '../../hooks/useCurrentUser';
import usePrevious from 'react-use/lib/usePrevious';


interface InnerTestProps {
	/**
	 * userId you want to call `setCurrentUser` with.
	 * Used this for testing that setCurrentUser actually updates
	 * the context for `useCurrentUser`
	 *
	 * @type {number}
	 * @memberof InnerTestProps
	 */
	setUserIdFromInside?:number;
}

function InnerTest(props:InnerTestProps) {
	const user = useCurrentUser<SetCurrentUserReturnType>();
	const {setUserIdFromInside} = props;
	const lastSetUserIdFromInside = usePrevious(setUserIdFromInside);
	useEffect(() => {
		if (setUserIdFromInside && lastSetUserIdFromInside !== setUserIdFromInside) {
			user.setCurrentUser({id:setUserIdFromInside});
		}
	}, [setUserIdFromInside, user, lastSetUserIdFromInside]);
	return (<>
		<div data-testid="userId">{user.currentUser?.id}</div>
		<div data-testid="signedIn">{user.signedIn.toString()}</div>
	</>);
}

/**
 *
 *
 * @param {(Parameters<typeof MockCurrentUserProvider>[0] & {setUserIdFromInside?:number})} props
 * setUserIdFromInside is a hacky and quick solution to testing this. Not bad in
 * this case but not great.
 * @returns
 */
function CurrentUserProviderWrapper(props: Parameters<typeof MockCurrentUserProvider>[0] & InnerTestProps) {


	return <MockCurrentUserProvider {...props}>
		<InnerTest setUserIdFromInside={props.setUserIdFromInside}/>
	</MockCurrentUserProvider>;
}

CurrentUserProviderWrapper.defaultProps = {
	updateAfterInitialize:false,
};


describe('MockCurrentUserProvider', () => {
	it('shows null and false when user passed  and signed in', async () => {
		expect.assertions(2);
		const result = render(<CurrentUserProviderWrapper initialUserId={null} />);
		const userIdElem = await result.findByTestId('userId');
		const signedIn = await result.findByTestId('signedIn');
		await waitFor(() => expect(userIdElem).toBeEmptyDOMElement());
		await waitFor(() => expect(signedIn).toHaveTextContent("false"));
	});

	it('shows 1 and true when user passed and signed in', async () => {
		expect.assertions(2);
		const result = render(<CurrentUserProviderWrapper initialUserId={1} />);
		const userIdElem = await result.findByTestId('userId');
		const signedIn = await result.findByTestId('signedIn');
		await waitFor(() => expect(userIdElem).toHaveTextContent("1"));
		await waitFor(() => expect(signedIn).toHaveTextContent("true"));
	});

	it('shows 2 and true when user passed and then updated', async () => {
		expect.assertions(2);
		const result = render(<CurrentUserProviderWrapper initialUserId={1} updateAfterInitialize/>);

		result.rerender(<CurrentUserProviderWrapper initialUserId={2} updateAfterInitialize/>);
		const userIdElem = await result.findByTestId('userId');
		const signedIn = await result.findByTestId('signedIn');
		await waitFor(() => expect(userIdElem).toHaveTextContent("2"));
		await waitFor(() => expect(signedIn).toHaveTextContent("true"));
	});

	it('shows null and false when user passed and then removed', async () => {
		expect.assertions(2);
		const result = render(<CurrentUserProviderWrapper initialUserId={1} updateAfterInitialize/>);

		result.rerender(<CurrentUserProviderWrapper initialUserId={null} updateAfterInitialize/>);
		const userIdElem = await result.findByTestId('userId');
		const signedIn = await result.findByTestId('signedIn');
		await waitFor(() => expect(userIdElem).toBeEmptyDOMElement());
		await waitFor(() => expect(signedIn).toHaveTextContent("false"));
	});

	it('shows 1 and true when user passed and then updated but no update user from Props', async () => {
		expect.assertions(2);
		const result = render(<CurrentUserProviderWrapper initialUserId={1} />);

		result.rerender(<CurrentUserProviderWrapper initialUserId={2} />);
		const userIdElem = await result.findByTestId('userId');
		const signedIn = await result.findByTestId('signedIn');
		expect(userIdElem).toHaveTextContent("1");
		expect(signedIn).toHaveTextContent("true");
	});

	it('shows 3 and true when user passed and then updated from setCurrentUser for the mock', async () => {
		expect.assertions(2);
		const result = render(<CurrentUserProviderWrapper initialUserId={1} />);

		result.rerender(<CurrentUserProviderWrapper initialUserId={1} setUserIdFromInside={3} />);
		const userIdElem = await result.findByTestId('userId');
		const signedIn = await result.findByTestId('signedIn');
		expect(userIdElem).toHaveTextContent("3");
		expect(signedIn).toHaveTextContent("true");
	});
});