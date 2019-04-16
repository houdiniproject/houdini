// License: LGPL-3.0-or-later
import React = require("react");
interface CloseButtonProps {
  backgroundCircleStyle:React.CSSProperties
  foregroundCircleStyle:React.CSSProperties
}

export const CloseButton = (props: CloseButtonProps) => { 
    return <svg
    width="24"
    height="24"
    viewBox="0 0 24 24"
    version="1.1">
   <circle
      cx="12"
      cy="12"
      r="10.65625"
      style={props.backgroundCircleStyle} />
   <circle
      cx="12"
      cy="12"
      r="9.25"
      style={props.foregroundCircleStyle} />
   <path
      d="M 7.130438,16.869562 16.869562,7.130438"
      style={{
        stroke: '#ffffff',
        strokeWidth:1.375,
        strokeLinecap:'square'
    }} />
   <path
      d="M 16.869562,16.869562 7.130438,7.130438"
      style={{
        stroke: '#ffffff',
        strokeWidth:1.375,
        strokeLinecap:'square'
    }} />
 </svg>
}