// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, Provider } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import { computed } from 'mobx';

export interface SelectableTableRowProps
{
  onSelect: () => void
}

/**
 * Passed via provider to children of the SelectableTableRow
 * @interface TableRowSelectHandler
 */
export interface TableRowSelectHandler {

  /**
   * Action to take on selection. A child of SelectableTableRow needs this
   * because there needs to be a focusable element for keyboard users to use
   * @memberof TableRowSelectHandler
   */
  onSelect: () => void
}

class SelectableTableRow extends React.Component<SelectableTableRowProps, {}> {


  render() {
     return <Provider SelectHandler={{onSelect: this.props.onSelect}}>
        <tr onClick={this.props.onSelect}>
          {this.props.children}
        </tr>
       </Provider>;
  }
}

export default observer(SelectableTableRow)



