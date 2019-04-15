import React = require("react");
import { Color } from "csstype";

interface CloseButtonProps {
  backgroundCircleStyle:React.CSSProperties
  foregroundCircleStyle:React.CSSProperties
}

export const CloseButton = (props: CloseButtonProps) => {
    return <svg
        width="32px"
        height="32px"
        viewBox="0 0 32 32"
        version="1.1">
        <circle
            cx="16"
            cy="16"
            r="15.5" style={props.backgroundCircleStyle}/>
        <circle
            style={props.foregroundCircleStyle}
            cx="16"
            cy="16"
            r="14" />
        <path
            d="M 8.917,23.083 23.083,8.917"
            style={{
                stroke: '#ffffff',
                strokeWidth:2,
                strokeLinecap:'square'
            }} />
        <path
            d="M 23.083,23.083 8.917,8.917"
            style={{
                stroke: '#ffffff',
                strokeWidth:2,
                strokeLinecap:'square'
            }} />
    </svg>
}