import { RootStore } from "../../lib/stores/root_store";
import { SupporterStore } from "../../lib/stores/supporter_store";
import { AddressStore } from "../../lib/stores/address_store";
import { SupporterAddressStore } from "./supporter_address_store";
import { SupporterPaneStore } from "./supporter_pane_store";

export class LocalRootStore {
    readonly supporterAddressStore: SupporterAddressStore;
    readonly supporterPaneStore: SupporterPaneStore;
    
    constructor(supporterId:number, rootStore:{supporterStore:SupporterStore, addressStore:AddressStore}) {
        this.supporterAddressStore = new SupporterAddressStore(supporterId, rootStore.supporterStore, rootStore.addressStore);
        this.supporterPaneStore = new SupporterPaneStore(this.supporterAddressStore)
    }
}