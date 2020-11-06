// License: LGPL-3.0-or-later
import * as React from "react";
import {render, act, fireEvent} from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import { shallow } from 'enzyme';

import SignInComponent from './SignInComponent';
import { SignInError } from "../../legacy_react/src/lib/api/errors";
import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../legacy_react/src/lib/api/sign_in');
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import useState from 'react';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;

function Wrapper(props:React.PropsWithChildren<unknown>) {
	return <IntlProvider messages={I18n.translations['en'] as any} locale={'en'}>
		<MockCurrentUserProvider>
			{props.children}
		</MockCurrentUserProvider>
	</IntlProvider>;
}


describe('SignInComponent', () => {
	it('signIn successfully', async() => {
		expect.assertions(2);
		const result = render(<Wrapper><SignInComponent/></Wrapper>);

		// we're getting the first element an attribute named 'data-testid' and a
		// of 'signInButton'
		const button = result.getByTestId('signInButton');

		// everytime you try to call the User SignIn API in this test, return a
		// promise which resolves to {id: 1}
		mockedWebUserSignIn.postSignIn.mockResolvedValue({id: 1});

		// act puts all of the related React updates for the click event into a
		// single update. Since fireEvent.click calls some promises, we need to make
		// the callback a Promise and await on act. If we didn't, our test wouldn't
		// wait for all the possible React changes to happen at once.
		await act(async () => {
			fireEvent.click(button);
		});

		const error = result.getByTestId('signInErrorDiv');
		const userId = result.getByTestId('currentUserDiv');

		expect(error).toBeEmptyDOMElement();
		expect(userId).toHaveTextContent("1");
	});

	it('signIn failed', async () => {
		expect.assertions(2);

		// everytime you try to call the User SignIn API in this test, return a
		// promise which rejects with a SignInError with status: 400 and data of
		// {error: 'Not Valid'}
		mockedWebUserSignIn.postSignIn.mockRejectedValueOnce(new SignInError({status: 400, data: {error: 'Not valid'}}));
		const result = render(<Wrapper><SignInComponent/></Wrapper>);

		const button = result.getByTestId('signInButton');
		await act(async () => {
			fireEvent.click(button);
		});

		const error = result.getByTestId('signInErrorDiv');
		const userId = result.getByTestId('currentUserDiv');

		expect(userId).toBeEmptyDOMElement();
		expect(error).toHaveTextContent('Not valid');
	});
});

/** Test that SignInComponent has email and password input fields, and a submit button  */
describe('SignInComponent', () => {
  it('has a login button', () => {
    const wrapper = shallow(<SignInComponent/>);
    expect(wrapper.containsMatchingElement(<button type="submit">Submit</button>)).toBeTruthy;
  });

  it('has a email input field', () => {
    const wrapper = shallow(<SignInComponent/>);
    expect(wrapper.containsMatchingElement(<input type="email" />)).toBeTruthy;
  });

  it('has a password input field', () => {
    const wrapper = shallow(<SignInComponent/>);
    expect(wrapper.containsMatchingElement(<input type="password" />)).toBeTruthy;
  });

  it('passes login information', () => {
    const email = 'tjgarlick@gmail.com';
    const password = '123password';
    const wrapper = shallow(<SignInComponent />);
      expect(email).toEqual(email);
      expect(password).toEqual(password);
    wrapper.find('button').simulate('click');
  });
});

// describe('Form', () => {
//   it('submit event when click submit', () => {
//     const callback = spy();
//     const wrapper = mount(
//     <Form onSubmit={ callback }>
//         <TextField id="email" name="email" type="email" />
//         <footer>
//           <Button caption="Send" display="primary" type="submit" />
//           <Button caption="Clear" type="reset" />
//         </footer>
//       </Form>
//     );
//     wrapper.find('[type="submit"]').get(0).click();
//     expect(callback).to.have.been.called();
//   });
// });



