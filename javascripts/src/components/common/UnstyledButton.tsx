// from: https://github.com/snowcoders/react-unstyled-button
// MIT license

import * as React from "react";

export interface IUnstyledButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    innerRefHandler?: (ref: HTMLButtonElement | null) => void;
    isBaseStylesDisabled?: boolean
}

export class UnstyledButton extends React.Component<IUnstyledButtonProps> {
    render() {
        let { isBaseStylesDisabled, type, style, innerRefHandler, ...htmlProps } = this.props;
        
        if (isBaseStylesDisabled !== true) {
            style = {...style,
                ...{
                    backgroundColor: 'transparent',
                    borderRadius: '0',
                    boxSizing: 'content-box',
                    border: "none",
                    color: 'inherit',
                    cursor: 'pointer',
                    display: 'inline-block',
                    font: 'inherit',
                    padding: '0',
                    textAlign: 'start',
                  }
                }
        }

        return <button ref={innerRefHandler} {...htmlProps} type={type || "button"} />;
    }
}