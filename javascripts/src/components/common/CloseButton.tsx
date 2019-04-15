import React = require("react");
import { action, observable } from "mobx";
import { Transition } from "react-transition-group";
import { CloseButton } from "./svg/CloseButton";
import color = require("color");

interface DefaultCloseButtonProps {
  onClick?: () => void
}

const mainColor = '#969696'
const darkenedColor = color(mainColor).darken(0.1).hex()

export class DefaultCloseButton extends React.Component<DefaultCloseButtonProps, {}> {
  @observable
  hovering: boolean

  @action.bound
  mouseOver() {
    this.hovering = true;
  }

  @action.bound
  mouseOut() {
    this.hovering = false;
  }

  render() {
    const defaultStyles ={
      foreground: {
        fill:mainColor
      },
      background: {
        stroke: mainColor,
        fill: '#FFFFFF'
      }
    }

    const states: {[state:string]:any} = {
      enter: {
        foreground: {
          fill: darkenedColor,
          transition: 'fill 500ms ease-in-out'
        },
        background: {
          stroke: darkenedColor,
          transition: 'stroke 500ms ease-in-out'
        }
      },
      exit: {
        foreground: {
          fill: mainColor,
          transition: 'fill 500ms ease-in-out'
        },
        background: {
          stroke: mainColor,
          transition: 'stroke 500ms ease-in-out'
        }
      }
    }

    return <Transition in={this.hovering} timeout={0}>
      {(state) => 
      <a onMouseOver={this.mouseOver} onMouseOut={this.mouseOut} onClick={this.props.onClick}>
        <CloseButton backgroundCircleStyle={
          {
            ...defaultStyles.background,
            ...((states[state] && states[state].background) || {})
          }}
          foregroundCircleStyle={
            {
              ...defaultStyles.foreground,
              ...((states[state] && states[state].foreground) || {})
            }
          }
          />
      </a>
    }
    </Transition>
  }

}
