const ReactOnRails = require('react-on-rails').default;
const SideNav = require('../components/common/SideNav/SideNavRenderFunc').default;
const TransactionTitle = require('../components/common/TransactionTitle/TransactionTitleRenderFunc').default;
// This is how react_on_rails can see SignInPage in the browser.
ReactOnRails.register({
	SideNav,
	TransactionTitle,
});
require('../../../client/css/global/page.css')
require('../legacy/page.js')
require('../legacy/nonprofits/payments/index/page.js')