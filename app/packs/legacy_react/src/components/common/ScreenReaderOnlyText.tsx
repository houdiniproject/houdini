// License: LGPL-3.0-or-later
import * as React from 'react';


class ScreenReaderOnlyText extends React.Component<Record<string,unknown>, Record<string,unknown>> {

	render() : JSX.Element {
		const style:React.CSSProperties = {
			position: 'absolute',
			width: '1px',
			height: '1px',
			padding: 0,
			margin: '-1px',
			overflow: 'hidden',
			clip: 'rect(0,0,0,0)',
			border: 0,
		};
		return <span style={style}>{this.props.children}</span>;
	}
}

export default ScreenReaderOnlyText;



