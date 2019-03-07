// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, propTypes } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';

export interface ButtonProps extends React.DetailedHTMLProps<React.ButtonHTMLAttributes<HTMLButtonElement>, HTMLButtonElement>
{
  //should be required but we're on typescript 2
  buttonSize?: 'tiny'|'default'|'large'|'jumbo'
}

class Button extends React.Component<ButtonProps, {}> {

  public static defaultProps = {
    buttonSize: "default"
  };

  winnowProps() : ButtonProps {
    let ourProps = {...this.props}
    delete ourProps.buttonSize
    return ourProps

  }

  render() {
    let className = 'button'
    if (this.props.buttonSize != 'default') {
      className += "--" + this.props.buttonSize
    }
    
    if(this.props.className) {
      className += " " + this.props.className
    }
    return <button {...this.winnowProps()} className={className}/>;
  }
}

export default Button



