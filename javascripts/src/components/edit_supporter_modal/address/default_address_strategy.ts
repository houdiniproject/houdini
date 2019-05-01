// License: LGPL-3.0-or-later
import * as _ from "lodash";
import { Address } from "../../../../api";
import { AddressAction } from "./AddressModalForm";


/**
 * Does this remind you of DefaultAddressStrategy::ManualStrategy?
 * It should!
 * @class DefaultAddressStategy
 */
export class DefaultAddressStrategy {

    constructor(
        private getAddresses: () => ReadonlyArray<Address>,
        private getDefaultAddressId: () => number,
        private setDefaultAddressId: (addressId?:number) => void
        ) {}

    handleAddressAction(action:AddressAction) {
        switch (action.type) {
          case 'add':
            this.handleAddedAddress(action)
            break;
          case 'delete':
            this.handleDeletedAddress(action)
            break;
          case 'update':
            this.handleUpdatedAddress(action)
            break;
          case 'none':
            break;
        }
      }

      private handleAddedAddress(action: AddressAction) {
        if (this.getAddresses().length === 1 || action.setToDefault){
          this.setDefaultAddressId(action.address.id)
        }
      }
    
      private handleDeletedAddress(action: AddressAction){
        // We delted our current default address Id
        if (this.getDefaultAddressId() === action.address.id)
        {
          const firstAddress = _.sortBy(this.getAddresses(), ['updated_at'])
          .reverse().shift()
          
          this.setDefaultAddressId(firstAddress && firstAddress.id)
          
        }
      }
    
      private handleUpdatedAddress(action:AddressAction) {
        if (action.setToDefault){
          this.setDefaultAddressId(action.address.id)
        }
      }
}