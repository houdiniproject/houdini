// License: LGPL-3.0-or-later
import { SupporterStore } from "../../lib/stores/supporter_store";
import { AddressStore } from "../../lib/stores/address_store";
import { SupporterEntity } from "./supporter_entity";
import { SupporterPaneStore } from "./supporter_pane_store";

export class LocalRootStore {
    readonly supporterEntity: SupporterEntity;
    readonly supporterPaneStore: SupporterPaneStore;
    
    constructor(supporterId:number, rootStore:{supporterStore:SupporterStore, addressStore:AddressStore}) {
        this.supporterEntity = new SupporterEntity(supporterId, rootStore.supporterStore, rootStore.addressStore);
        this.supporterPaneStore = new SupporterPaneStore(this.supporterEntity)
    }
}