/**
 * Defines the React 16 Adapter for Enzyme.
 *
 * @link http://airbnb.io/enzyme/docs/installation/#working-with-react-16
 * @copyright 2017 Airbnb, Inc.
 */
 const enzyme = require("enzyme");
 const Adapter = require("@wojtekmaj/enzyme-adapter-react-17");

 enzyme.configure({ adapter: new Adapter() });

const {setGlobalConfig} =  require('@storybook/testing-react')
const globalStorybookConfig = require('./.storybook/react/preview_common'); // path of your preview.js file

setGlobalConfig(globalStorybookConfig);

