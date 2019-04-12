// License: LGPL-3.0-or-later
import * as React from 'react';

const lpf = jest.genMockFromModule('../LoadedPaneFormik') as React.Component

lpf.render = () =>  <div></div>;

export default  lpf



