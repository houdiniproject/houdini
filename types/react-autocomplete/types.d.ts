export interface AutocompletePropsGeneric<T> {
    /**
     * The items to display in the dropdown menu
     */
    items: Array<T>,
    /**
     * The value to display in the input field
     */
    value?: any,
    /**
     * Arguments: `event: Event, value: String`
     *
     * Invoked every time the user changes the input's value.
     */
    onChange?: (event:Event, value:string) => void,
    /**
     * Arguments: `value: String, item: Any`
     *
     * Invoked when the user selects an item from the dropdown menu.
     */
    onSelect?: (value:String, item:T) => void
    /**
     * Arguments: `item: Any, value: String`
     *
     * Invoked for each entry in `items` and its return value is used to
     * determine whether or not it should be displayed in the dropdown menu.
     * By default all items are always rendered.
     */
    shouldItemRender?: (item:T, value:string) => boolean
    /**
     * Arguments: `item: Any`
     *
     * Invoked when attempting to select an item. The return value is used to
     * determine whether the item should be selectable or not.
     * By default all items are selectable.
     */
    isItemSelectable?: (item:T) => boolean,
    /**
     * Arguments: `itemA: Any, itemB: Any, value: String`
     *
     * The function which is used to sort `items` before display.
     */
    sortItems?: (itemA:T, itemB:T, value:string) => number
    /**
     * Arguments: `item: Any`
     *
     * Used to read the display value from each entry in `items`.
     */
    getItemValue: (item:T) => string
    /**
     * Arguments: `item: Any, isHighlighted: Boolean, styles: Object`
     *
     * Invoked for each entry in `items` that also passes `shouldItemRender` to
     * generate the render tree for each item in the dropdown menu. `styles` is
     * an optional set of styles that can be applied to improve the look/feel
     * of the items in the dropdown menu.
     */
    renderItem: (item: T, isHighlighted:boolean, styles?:any) => ReactNode
    /**
     * Arguments: `items: Array<Any>, value: String, styles: Object`
     *
     * Invoked to generate the render tree for the dropdown menu. Ensure the
     * returned tree includes every entry in `items` or else the highlight order
     * and keyboard navigation logic will break. `styles` will contain
     * { top, left, minWidth } which are the coordinates of the top-left corner
     * and the width of the dropdown menu.
     */
    renderMenu?: (items: Array<T>, value:String, style:{top:string, left:string, minWidth:string}) => ReactNode
    /**
     * Styles that are applied to the dropdown menu in the default `renderMenu`
     * implementation. If you override `renderMenu` and you want to use
     * `menuStyle` you must manually apply them (`this.props.menuStyle`).
     */
    menuStyle?: any,
    /**
     * Arguments: `props: Object`
     *
     * Invoked to generate the input element. The `props` argument is the result
     * of merging `props.inputProps` with a selection of props that are required
     * both for functionality and accessibility. At the very least you need to
     * apply `props.ref` and all `props.on<event>` event handlers. Failing to do
     * this will cause `Autocomplete` to behave unexpectedly.
     */
    renderInput?: (props:any) => ReactNode,
    /**
     * Props passed to `props.renderInput`. By default these props will be
     * applied to the `<input />` element rendered by `Autocomplete`, unless you
     * have specified a custom value for `props.renderInput`. Any properties
     * supported by `HTMLInputElement` can be specified, apart from the
     * following which are set by `Autocomplete`: value, autoComplete, role,
     * aria-autocomplete. `inputProps` is commonly used for (but not limited to)
     * placeholder, event handlers (onFocus, onBlur, etc.), autoFocus, etc..
     */
    inputProps?: any,
    /**
     * Props that are applied to the element which wraps the `<input />` and
     * dropdown menu elements rendered by `Autocomplete`.
     */
    wrapperProps?: any
    /**
     * This is a shorthand for `wrapperProps={{ style: <your styles> }}`.
     * Note that `wrapperStyle` is applied before `wrapperProps`, so the latter
     * will win if it contains a `style` entry.
     */
    wrapperStyle?: any
    /**
     * Whether or not to automatically highlight the top match in the dropdown
     * menu.
     */
    autoHighlight?: boolean,
    /**
     * Whether or not to automatically select the highlighted item when the
     * `<input>` loses focus.
     */
    selectOnBlur?: boolean,
    /**
     * Arguments: `isOpen: Boolean`
     *
     * Invoked every time the dropdown menu's visibility changes (i.e. every
     * time it is displayed/hidden).
     */
    onMenuVisibilityChange?: (isOpen:boolean) => void
    /**
     * Used to override the internal logic which displays/hides the dropdown
     * menu. This is useful if you want to force a certain state based on your
     * UX/business logic. Use it together with `onMenuVisibilityChange` for
     * fine-grained control over the dropdown menu dynamics.
     */
    open?: boolean,
    debug?: boolean
    [prop:string]: any

}
export interface AutocompleteProps extends AutocompletePropsGeneric<any> {

}