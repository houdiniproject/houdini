//MIT based on https://github.com/davidtheclark/react-aria-tabpanel/blob/master/lib/TabList.js
import * as React from 'react'
import specialAssign from "./specialAssign";
import {observer} from 'mobx-react';

const PropTypes = require('prop-types');

const checkedProps = {
  children: PropTypes.node.isRequired,
  tag: PropTypes.string,
};

interface TabListProps {
  tag?: string

  [prop: string]: any
}

@observer
export class TabList extends React.Component<TabListProps> {
  displayName: 'AriaTabPanel-TabList';

  public static defaultProps = {tag: 'div'};

  static contextTypes = {
    atpManager: PropTypes.object.isRequired
  };

  render() {
    const props = this.props;
    let elProps = {
      role: 'tablist',
    };
    specialAssign(elProps, props, checkedProps);
    return React.createElement(props.tag, elProps, props.children);
  }
}