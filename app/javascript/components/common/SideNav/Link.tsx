// License: LGPL-3.0-or-later
// from app/views/layouts/_user_menu.html.erb

import classNames from 'classnames';
import React from 'react';


export default function Link({ className = '', ...props}: React.ComponentPropsWithoutRef<"a">): JSX.Element {
	return (<a {...props} className={classNames(...className, 'sideNav-link')}/>);
}
