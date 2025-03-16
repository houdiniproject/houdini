import * as models from './models';

/**
 * Register a nonprofit
 */
export interface PostNonprofit {
    nonprofit: models.PostNonprofitNonprofit;

    user: models.PostNonprofitUser;

}
export class PostNonprofitException implements Error{

    constructor(obj:PostNonprofit, message?:string){
            this.item = obj;

    }

    message: string;
    stack: string;
    name: string;

    item: PostNonprofit;
}


