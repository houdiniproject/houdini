// License: LGPL-3.0-or-later
import * as React from 'react';
import { TableRowSelectHandlerProvider } from './connect';

export interface SelectableTableRowProps
  {/**
  * Action you want to take when the row is selected
  * @memberof SelectableTableRowProps
  */
  onSelect: () => void
}

/**
 * So you want a table row that fires an action when any part of the row is clicked. Well that's what the SelectableTableRow does for you. Is it Aria compatible? Not yet!
 * @class SelectableTableRow
 * @extends React.Component<SelectableTableRowProps, {}>
 */
class SelectableTableRow extends React.Component<SelectableTableRowProps, {}> {
  render() {
     return <TableRowSelectHandlerProvider value={{onSelect: this.props.onSelect}}>
        <tr onClick={this.props.onSelect}>
          {this.props.children}
        </tr>
       </TableRowSelectHandlerProvider>;
  }
}

export default SelectableTableRow



