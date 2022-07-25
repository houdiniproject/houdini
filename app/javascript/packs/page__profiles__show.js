const ReactOnRails = require('react-on-rails').default;
const SideNav = require('../components/common/SideNav/SideNavRenderFunc').default;

// This is how react_on_rails can see SignInPage in the browser.
ReactOnRails.register({
	SideNav,
});
require('../legacy/page.js')