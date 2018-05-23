// License: LGPL-3.0-or-later
import * as React from 'react'
import * as RAT from "react-aria-tabpanel";
import {TabManager} from "./manager";
var PropTypes = require('prop-types');

var innerCreateManager = require('react-aria-tabpanel/lib/createManager');
var specialAssign = require('react-aria-tabpanel/lib/specialAssign');

interface AddManagerInterface {
    manager?: TabManager
}


var checkedProps = {
    children: PropTypes.node.isRequired,
    activeTabId: PropTypes.string,
    letterNavigation: PropTypes.bool,
    onChange: PropTypes.func,
    tag: PropTypes.string,
};

/**
 * Works just like the normal Wrapper but provides a tool for passing in our own TabManager
 */
export class ManagedWrapper extends RAT.Wrapper<AddManagerInterface>
{
  manager: TabManager
  constructor(props:RAT.WrapperProps & AddManagerInterface){
      super(props)

      if (props.manager)
          this.manager = this.props.manager
  }

  componentWillMount(){

       console.log('seomte')

  }

  render() {
      var props = this.props;
      var elProps = {};
      specialAssign(elProps, props, checkedProps);
      return React.createElement(props.tag, elProps, props.children);
  }



}


