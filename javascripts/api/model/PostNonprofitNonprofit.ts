/**
 * API title
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * OpenAPI spec version: 0.0.1
 * 
 *
 * NOTE: This class is auto generated by the swagger code generator program.
 * https://github.com/swagger-api/swagger-codegen.git
 * Do not edit the class manually.
 */

import * as models from './models';

export interface PostNonprofitNonprofit {
    /**
     * Organization Name
     */
    name: string;

    /**
     * Organization website URL
     */
    website?: string;

    /**
     * Organization Address ZIP Code
     */
    zip_code: string;

    /**
     * Organization Address State Code
     */
    state_code: string;

    /**
     * Organization Address City
     */
    city: string;

    /**
     * Organization email (public)
     */
    email?: string;

    /**
     * Organization phone (public)
     */
    phone?: string;

}
export class PostNonprofitNonprofitException implements Error{

    constructor(obj:PostNonprofitNonprofit, message?:string){
            this.item = obj;
    }

    message: string;
    stack: string;
    name: string;

    item: PostNonprofitNonprofit;
}


