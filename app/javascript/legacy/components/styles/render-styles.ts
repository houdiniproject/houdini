// License: LGPL-3.0-or-later
export default function renderStyles(_: unknown): (styles: string) => void {
	const styleTag = document.createElement('style');
	return (styles: string) => {
		styleTag.innerHTML = styles;
		document.querySelector('head')?.appendChild(styleTag);
	};
}

