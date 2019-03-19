// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import ScreenReaderOnlyText from './ScreenReaderOnlyText';
import { VelocityComponent } from 'velocity-react';

export interface SpinnerProps
{
  size: 'small'| 'normal'| 'large'
}

class Spinner extends React.Component<SpinnerProps, {}> {

   generateStyle() : React.CSSProperties {
    const spinnerWidth = '100px'
    const spinnerHeight = '100px'
    const spinnerBorderWidth = '3px'

     return {
      display: 'inline-block',
      width: spinnerWidth,
      height: spinnerHeight,
      verticalAlign: 'text-bottom',
      border: `${spinnerBorderWidth} solid currentColor`,
      borderRightColor: 'transparent',
      borderRadius: '50%',
     }
    
  }
  render() {
     return <VelocityComponent animation={{rotateZ: 360}} duration={750} loop={true} easing={'linear'} runOnMount={true}>
      <div style={this.generateStyle()} role="status">
      <ScreenReaderOnlyText>Loading...</ScreenReaderOnlyText>
    </div>
   </VelocityComponent>;
  }
}

export default Spinner;



