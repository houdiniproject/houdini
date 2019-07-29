// License: LGPL-3.0-or-later
import * as React from 'react';

const lpf = jest.genMockFromModule('../FieldCreator') as React.Component

lpf.render = () =>  <div></div>;

export default  lpf



