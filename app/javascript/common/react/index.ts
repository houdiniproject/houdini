// License: LGPL-3.0-or-later

/**
 * Adds type safety to your default props.
 *
 * @example
 * // your component
 * function CustomComponent(props:{className:string, disabled?:boolean}) : JSX.Element {
 * 	// not show for
 * }
 *
 * CustomComponent.defaultProps = defaultProps(CustomComponent, {
 * 	className: 'another'
 * })
 *
 * @example <caption>Function properly typechecks</caption>
 * // use the same component as previous example
 * CustomComponent.defaultProps = defaultProps(CustomComponent, {
 * 	className: 'another',
 * 	unexpectedProp: 3 // <-- Typecheck will throw a compile error because you didn't expect this.
 * })
 *
 * @param {(props:TProperty) => JSX.Element} _component - the component you want to create default props for
 * @param {Partial<TProperty>} defaultProps - the defaultProps for your component
 * @returns defaultProps
 * */
export function defaultProps<TProperty>(_component:(props:TProperty) => JSX.Element, defaultProps:Partial<TProperty>):Partial<TProperty> {
	return defaultProps;
}