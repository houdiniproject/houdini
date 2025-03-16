/**
 * Return a nonprofit.
 */
export interface Nonprofit {
    id?: string;

}
export class NonprofitException implements Error{

    constructor(obj:Nonprofit, message?:string){
            this.item = obj;
    }

    message: string;
    stack: string;
    name: string;

    item: Nonprofit;
}


