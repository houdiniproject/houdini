import ReactOnRails from 'react-on-rails';
require('bootstrap-loader');
import SessionLoginPage from '../legacy_react/app/session_login_page';

// This is how react_on_rails can see SessionLoginPage in the browser.
ReactOnRails.register({
	SessionLoginPage,
});
