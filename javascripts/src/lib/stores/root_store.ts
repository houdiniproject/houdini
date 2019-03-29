// License: LGPL-3.0-or-later
import { ApiManager } from "../api_manager";
import { APIS } from "../../../api";
import { CSRFInterceptor } from "../csrf_interceptor";
import { SupporterStore } from "./supporter_store";
import { AddressStore } from "./address_store";

export class RootStore {
    apiManager: ApiManager;
    supporterStore: SupporterStore;
    addressStore: AddressStore;

    constructor(apiManager?:ApiManager){
        this.apiManager = apiManager || new ApiManager(APIS, CSRFInterceptor)
        this.supporterStore = new SupporterStore(this)
        this.addressStore = new AddressStore(this)
    }
}