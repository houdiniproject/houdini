//MIT based on https://github.com/davidtheclark/react-aria-tabpanel/blob/master/lib/TabPanel.js
import * as React from 'react'
import specialAssign from "./specialAssign";
import {TabManagerParent} from "./abstract_tabcomponent_state";
import {observer} from 'mobx-react';

const PropTypes = require('prop-types');

const checkedProps = {
  children: PropTypes.oneOfType([
    PropTypes.node,
    PropTypes.func,
  ]).isRequired,
  tabId: PropTypes.string.isRequired,
  tag: PropTypes.string,
  active: PropTypes.bool,
};

interface TabPanelProps {
  tabId: string
  active: boolean
  tag?: string

  [prop: string]: any
}

@observer
export class TabPanel extends React.Component<TabPanelProps> {
  displayName: 'AriaTabPanel-TabPanel';

  public static defaultProps = {tag: 'div'};

  static contextTypes = {
    atpManager: PropTypes.object.isRequired
  };

  context: { atpManager: TabManagerParent };

  handleKeyDown(event: any) {
    if (event.ctrlKey && event.key === 'ArrowUp') {
      event.preventDefault();
      this.context.atpManager.focusTab(this.props.tabId);
    }
  }

  registerWithManager(el: any) {

    this.context.atpManager.registerTabPanelElement({
      node: el,
      tabId: this.props.tabId,
    });
  }

  render() {
    const props = this.props;
    const isActive = props.active;

    const kids = props.children;

    let style = props.style || {};
    if (!isActive) {
      style.display = 'none';
    }

    let elProps = {
      className: props.className,
      id: this.context.atpManager.getTabPanelId(props.tabId),
      onKeyDown: this.handleKeyDown.bind(this),
      role: 'tabpanel',
      style: style,
      'aria-hidden': !isActive,
      'aria-describedby': props.tabId,
      ref: this.registerWithManager.bind(this)
    };
    specialAssign(elProps, props, checkedProps);

    return React.createElement(props.tag, elProps, kids);
  }
}