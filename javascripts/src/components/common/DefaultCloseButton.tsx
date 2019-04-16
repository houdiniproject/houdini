import React = require("react");
import { action, observable } from "mobx";
import { Transition } from "react-transition-group";
import { CloseButton } from "./svg/CloseButton";
import color = require("color");
import { observer } from "mobx-react";
import ScreenReaderOnlyText from "./ScreenReaderOnlyText";

interface DefaultCloseButtonProps {
  onClick?: () => void
}

const mainColor = '#969696'
const darkenedColor = color(mainColor).darken(0.1).hex()
const defaultStyles = {
  foreground: {
    fill: mainColor
  },
  background: {
    stroke: mainColor,
    fill: '#FFFFFF'
  }
}

const states: { [state: string]: any } = {
  entering: {
    foreground: {
      fill: darkenedColor,
      transition: 'fill 250ms ease-in-out'
    },
    background: {
      stroke: darkenedColor,
      transition: 'stroke 250ms ease-in-out'
    }
  },
  entered: {
    foreground: {
      fill: darkenedColor,
    },
    background: {
      stroke: darkenedColor,
    }
  },
  exiting: {
    foreground: {
      fill: mainColor,
      transition: 'fill 250ms ease-in-out'
    },
    background: {
      stroke: mainColor,
      transition: 'stroke 250ms ease-in-out'
    }
  },
  exited: {
    foreground: {
      fill: mainColor,
    },
    background: {
      stroke: mainColor,
    }
  }
}

@observer
export class DefaultCloseButton extends React.Component<DefaultCloseButtonProps, {}> {
  @observable
  hovering: boolean

  @observable
  focusing: boolean

  @action.bound
  mouseEnter() {
    this.hovering = true;
  }

  @action.bound
  mouseLeave() {
    this.hovering = false;
  }

  @action.bound
  keyDown(event: React.KeyboardEvent<HTMLAnchorElement>) {
    if (event.key == 'Enter') {
      event.preventDefault();
      this.props.onClick();
    }
  }

  render() {
    return <Transition in={this.hovering} timeout={250}>
      {(hoverState) => {
        const backgroundStyle = {
          ...defaultStyles.background,
          ...((states[hoverState] && states[hoverState].background) || {})
        }

        const foregroundStyle =
        {
          ...defaultStyles.foreground,
          ...((states[hoverState] && states[hoverState].foreground) || {})
        }

        return <a onMouseEnter={this.mouseEnter} onMouseLeave={this.mouseLeave} onClick={this.props.onClick} onKeyDown={this.keyDown} tabIndex={0} className={'focusable_item'}>
          <CloseButton backgroundCircleStyle={backgroundStyle}
            foregroundCircleStyle={foregroundStyle}
          /><ScreenReaderOnlyText>Close modal</ScreenReaderOnlyText>
        </a>

      }
      }
    </Transition>

  }
}
