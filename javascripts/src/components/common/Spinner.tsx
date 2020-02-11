// License: LGPL-3.0-or-later
import { Color } from 'csstype';
import * as React from 'react';
import { VelocityComponent } from 'velocity-react';
import ScreenReaderOnlyText from './ScreenReaderOnlyText';

export interface SpinnerProps {
  size: 'small' | 'normal' | 'large' | 'extralarge'
  color?: Color
}

function generateStyle(size:'small'|'normal'|'large'|'extralarge', color:string): React.CSSProperties {
  let spinnerDimension: number
  let spinnerBorderWidth: number = 3
  switch (size) {
    case 'small':
      spinnerDimension = 25
      break;
    case 'normal':
      spinnerDimension = 50
      break;
    case 'large':
      spinnerDimension = 100
      break;
    case 'extralarge':
      spinnerDimension = 200
      break;
  }

  return {
    display: 'inline-block',
    width: `${spinnerDimension}px`,
    height: `${spinnerDimension}px`,
    verticalAlign: 'text-bottom',
    border: `${spinnerBorderWidth}px solid ${color}`,
    borderRightColor: 'transparent',
    borderRadius: '50%',
  }
}

const Spinner:React.StatelessComponent<SpinnerProps> = (props) =>{
  return <VelocityComponent animation={{ rotateZ: 360 }} duration={750} loop={true} easing={'linear'} runOnMount={true}>
  <div style={generateStyle(props.size, props.color)} role="status">
    <ScreenReaderOnlyText>Loading...</ScreenReaderOnlyText>
  </div>
</VelocityComponent>;
};

Spinner.defaultProps = {
  color: 'currentcolor'
};

Spinner.displayName = "Spinner"

export default Spinner;



