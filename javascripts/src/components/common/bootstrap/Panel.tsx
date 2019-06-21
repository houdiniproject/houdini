// License: LGPL-3.0-or-later
import * as React from 'react';

export interface PanelProps
{
  headerRender: () => JSX.Element
  render:()=> JSX.Element
}

class Panel extends React.Component<PanelProps, {}> {
  render() {
     return <div className={"panel panel-default"}>
       <div className="panel-heading">{this.props.headerRender()}</div>
       <div className={'panel-body'}>
         {this.props.render()}
       </div>
     </div>
  }
}

export default Panel




