/* eslint-disable @typescript-eslint/no-explicit-any */
// License: LGPL-3.0-or-later
// declaration for various Webpack imports so Typescript doesn't cry
declare module "*.png" {
  const content: any;
  export default content;
}

declare module "*.svg" {
  const content: any;
  export default content;
}

declare module "*.jpg" {
	const content: any;
  export default content;
}