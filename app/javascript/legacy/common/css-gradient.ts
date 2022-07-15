// License: LGPL-3.0-or-later
export default function cssGradient(dir: string, to: string, from: string):string {
	return ` background-image: -webkit-linear-gradient(${dir}, ${to}, ${from});
background-image: -moz-linear-gradient(${dir}, ${to}, ${from});
background-image: -ms-linear-gradient(${dir}, ${to}, ${from});
background-image: linear-gradient(${dir}, ${to}, ${from});
filter: progid:DXImageTransform.Microsoft.gradient(GradientType=1,startColorstr=${to}, endColorstr=${from});`;
}

