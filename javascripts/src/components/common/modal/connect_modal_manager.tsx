//License: LGPL-3.0-or-later
//https://github.com/jaredpalmer/formik/blob/master/src/connect.tsx
import React = require("react");
import hoistNonReactStatics = require('hoist-non-react-statics');
import { ModalManagerInterface} from "./modal_manager";

export const {
    Provider: ModalManagerProvider,
    Consumer: ModalManagerConsumer,
  } = React.createContext<ModalManagerInterface>({} as any);

export interface ModalManagerContextProps {
  modalManager: ModalManagerInterface
}

/**
 * Connect any component to Formik context, and inject as a prop called `modal`;
 * @param Comp React Component
 */
export function connectModalManager<OuterProps>(
    Comp: React.ComponentType<OuterProps & ModalManagerContextProps>
  ) {
    const C: React.SFC<OuterProps> = (props: OuterProps) => (
      <ModalManagerConsumer>
        {modalManager => <Comp {...props} modalManager={modalManager} />}
      </ModalManagerConsumer>
    );
    const componentDisplayName =
      Comp.displayName ||
      'Component';
  
    // Assign Comp to C.WrappedComponent so we can access the inner component in tests
    // For example, <Field.WrappedComponent /> gets us <FieldInner/>
    (C as React.SFC<OuterProps> & {
      WrappedComponent: React.ReactNode;
    }).WrappedComponent = Comp;
  
    C.displayName = `ModalManagerConnect(${componentDisplayName})`;
  
    return hoistNonReactStatics(
      C,
      Comp as React.ComponentClass<OuterProps & ModalManagerContextProps> // cast type to ComponentClass (even if SFC)
    );
  }