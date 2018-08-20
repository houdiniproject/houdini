//MIT based on https://github.com/davidtheclark/react-aria-tabpanel/blob/master/lib/Tab.js
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
  id: PropTypes.string.isRequired,
  tag: PropTypes.string,
  role: PropTypes.string,
  index: PropTypes.number,
  active: PropTypes.bool,
  letterNavigationText: PropTypes.string,
};

interface TabProps {
  id: string
  active: boolean
  letterNavigationText?: string
  tag?: string

  [prop: string]: any
}

@observer
export class Tab extends React.Component<TabProps> {
  displayName: 'AriaTabPanel-Tab';

  public static defaultProps = { tag: 'div', role: 'tab' };

  static contextTypes = {
    atpManager: PropTypes.object.isRequired
  };

   context: {atpManager:TabManagerParent};
  elRef:any;

  handleRef(el:any) {
    if (el) {
      this.elRef = el;
      this.registerWithManager(this.elRef);
    }
  }

  registerWithManager(elRef:any){
    this.context.atpManager.registerTabElement({
      id: this.props.id,
      node: elRef
    });
  }

  handleFocus() {
    this.context.atpManager.handleTabFocus(this.props.id);
  }

  render() {
    const props = this.props;
    const isActive =  props.active;

    const kids = props.children;

    let elProps = {
      id: props.id,
      tabIndex: (isActive) ? 0 : -1,
      onFocus: this.handleFocus.bind(this),
      role: props.role,
      'aria-selected': isActive,
      'aria-controls': this.context.atpManager.getTabPanelId(props.id),
      ref: this.handleRef.bind(this)
    };
    specialAssign(elProps, props, checkedProps);

    return React.createElement(props.tag, elProps, kids);
  }

  componentWillUnmount(){
    this.context.atpManager.unregisterTabElement({id:this.props.id})
  }

}