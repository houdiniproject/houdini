// License: LGPL-3.0-or-later
import ReactOnRails from 'react-on-rails';
import SignInPage from '../components/users/SignInPageRenderFunc';

// This is how react_on_rails can see SessionLoginPage in the browser.
ReactOnRails.register({
	SignInPage,
});
