// License: LGPL-3.0-or-later
import * as React from 'react';
import _ = require('lodash');

export default class ModalFooter extends React.Component<{ children: React.ReactNode[] }, {}> {
  render() {
    return <footer className={'modal-footer'} style={{ textAlign: 'right' }}>
      {
        this.props.children.map((e: React.ReactElement<any>, index: number, array) => {
          const onLastItem = array.length - 1 == index;
          const style = onLastItem ? {} : { marginRight: '10px' }
          return <span style={style} key={e.key}>
            {e}
          </span>
        })
      }
    </footer>
  }
}



