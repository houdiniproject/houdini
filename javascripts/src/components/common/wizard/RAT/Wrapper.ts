// License: LGPL-3.0-or-later
import * as React from 'react'
import {ReactNode} from 'react'
import {TabManagerParent} from "./abstract_tabcomponent_state";
import {observer} from 'mobx-react';
import specialAssign from "./specialAssign";

import PropTypes = require('prop-types');

interface WrapperProps {
  manager: TabManagerParent
  tag?: string
  children: ReactNode
  [props:string]: any
}

const checkedProps = {
  children: PropTypes.node.isRequired,
  tag: PropTypes.string,
  manager: PropTypes.object.isRequired
};

/**
 * Works just like the normal Wrapper but supports our own tab manager
 */
@observer
export class Wrapper extends React.Component<WrapperProps> {

  displayName = 'AriaTabPanel-Wrapper';

  public static defaultProps = {
    tag: 'div'
  };

  public static childContextTypes = {
    atpManager: PropTypes.object.isRequired,
  };

  getChildContext() {
    return {atpManager: this.props.manager};
  }

  componentWillUnmount() {
    this.props.manager.destroy();
  }

  componentDidMount() {
    this.props.manager.activate();
  }

  render() {
    const props = this.props;
    let elProps = {};
    specialAssign(elProps, props, checkedProps);
    return React.createElement(props.tag, elProps, props.children);
  }
}
