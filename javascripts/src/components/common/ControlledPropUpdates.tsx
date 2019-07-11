// License: LGPL-3.0-or-later
import * as React from 'react';

export interface ControlledPropUpdatesProps<T>
{
  initialValues:T
  render:(values:T) => JSX.Element
}

/**
 * A wrapper component that accepts initial values but ignores future changes.
 * @class ControlledPropUpdates
 * @extends React.Component<ControlledPropUpdatesProps<T>, {values:T}>
 * @template T 
 */
class ControlledPropUpdates<T> extends React.Component<ControlledPropUpdatesProps<T>, {values:T}> {

  constructor(props: ControlledPropUpdatesProps<T>) {
    super(props)
    this.state = {values: props.initialValues}
  }
  
  static defaultProps = {
    initialValues: {}
  }

  render() {
    return this.props.render(this.state.values);
  }

}

export default ControlledPropUpdates;



