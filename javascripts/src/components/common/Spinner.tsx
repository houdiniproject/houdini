// License: LGPL-3.0-or-later
import { Color } from 'csstype';
import * as React from 'react';
import { VelocityComponent } from 'velocity-react';
import ScreenReaderOnlyText from './ScreenReaderOnlyText';

export interface SpinnerProps {
  size: 'small' | 'normal' | 'large'
  color?: Color
}

class Spinner extends React.Component<SpinnerProps, {}> {
  static defaultProps = {
    color: 'currentcolor'
  }

  generateStyle(): React.CSSProperties {
    let spinnerDimension: number
    let spinnerBorderWidth: number = 3
    switch (this.props.size) {
      case 'small':
        spinnerDimension = 25
        break;
      case 'normal':
        spinnerDimension = 50
        break;
      case 'large':
        spinnerDimension = 100
        break;
    }

    return {
      display: 'inline-block',
      width: `${spinnerDimension}px`,
      height: `${spinnerDimension}px`,
      verticalAlign: 'text-bottom',
      border: `${spinnerBorderWidth}px solid ${this.props.color}`,
      borderRightColor: 'transparent',
      borderRadius: '50%',
    }

  }
  render() {
    return <VelocityComponent animation={{ rotateZ: 360 }} duration={750} loop={true} easing={'linear'} runOnMount={true}>
      <div style={this.generateStyle()} role="status">
        <ScreenReaderOnlyText>Loading...</ScreenReaderOnlyText>
      </div>
    </VelocityComponent>;
  }
}

export default Spinner;



