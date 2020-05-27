//License: LGPL-3.0-or-later
//https://github.com/jaredpalmer/formik/blob/master/src/connect.tsx
import React = require("react");
import hoistNonReactStatics = require('hoist-non-react-statics');


/**
 * Passed via provider to children of the SelectableTableRow
 * @interface TableRowSelectHandler
 */
export interface TableRowSelectHandlerContext {

  /**
   * Action to take on selection. A child of SelectableTableRow needs this
   * because there needs to be a focusable element for keyboard users to use
   * @memberof TableRowSelectHandler
   */
  selectHandler: {
    onSelect: () => void
  }
}

export const {
    Provider: TableRowSelectHandlerProvider,
    Consumer: TableRowSelectHandlerConsumer,
  } = React.createContext<{
    onSelect: () => void
  }>({} as any);


/**
 * Connect any component to Formik context, and inject as a prop called `modal`;
 * @param Comp React Component
 */
export function connectTableRowSelectHandler<OuterProps>(
    Comp: React.ComponentType<OuterProps & TableRowSelectHandlerContext>
  ) {
    const C: React.SFC<OuterProps> = (props: OuterProps) => (
      <TableRowSelectHandlerConsumer>
        {selectHandler => <Comp {...props} selectHandler={selectHandler} />}
      </TableRowSelectHandlerConsumer>
    );
    const componentDisplayName =
      Comp.displayName ||
      'Component';
  
    // Assign Comp to C.WrappedComponent so we can access the inner component in tests
    // For example, <Field.WrappedComponent /> gets us <FieldInner/>
    (C as React.SFC<OuterProps> & {
      WrappedComponent: React.ReactNode;
    }).WrappedComponent = Comp;
  
    C.displayName = `TableRowSelectHandlerConnect(${componentDisplayName})`;
  
    return hoistNonReactStatics(
      C,
      Comp as React.ComponentClass<OuterProps & TableRowSelectHandlerContext> // cast type to ComponentClass (even if SFC)
    );
  }