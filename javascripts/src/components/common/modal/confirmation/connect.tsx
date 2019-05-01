//License: LGPL-3.0-or-later
//https://github.com/jaredpalmer/formik/blob/master/src/connect.tsx
import React = require("react");
import hoistNonReactStatics = require('hoist-non-react-statics');
import { ConfirmationManager } from "./confirmation_manager";

export interface ConfirmationManagerContextProps {
  confirmation: ConfirmationManager
}

export const {
    Provider: ConfirmationManagerProvider,
    Consumer: ConfirmationManagerConsumer,
  } = React.createContext<ConfirmationManager>({} as any);


/**
 * Connect any component to Formik context, and inject as a prop called `modal`;
 * @param Comp React Component
 */
export function connectConfirmationManager<OuterProps>(
    Comp: React.ComponentType<OuterProps & ConfirmationManagerContextProps>
  ) {
    const C: React.SFC<OuterProps> = (props: OuterProps) => (
      <ConfirmationManagerConsumer>
        {confManager => <Comp {...props} confirmation={confManager} />}
      </ConfirmationManagerConsumer>
    );
    const componentDisplayName =
      Comp.displayName ||
      'Component';
  
    // Assign Comp to C.WrappedComponent so we can access the inner component in tests
    // For example, <Field.WrappedComponent /> gets us <FieldInner/>
    (C as React.SFC<OuterProps> & {
      WrappedComponent: React.ReactNode;
    }).WrappedComponent = Comp;
  
    C.displayName = `ConfirmationManagerConnect(${componentDisplayName})`;
  
    return hoistNonReactStatics(
      C,
      Comp as React.ComponentClass<OuterProps & ConfirmationManagerContextProps> // cast type to ComponentClass (even if SFC)
    );
  }