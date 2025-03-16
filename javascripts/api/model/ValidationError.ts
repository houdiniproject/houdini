export interface ValidationError {
    /**
     * Params where the following had an error.
     */
    params?: Array<string>;

    /**
     * The validation messages for the params
     */
    messages?: Array<string>;

}
export class ValidationErrorException implements Error{

    constructor(obj:ValidationError, message?:string){
            this.item = obj;
    }

    message: string;
    stack: string;
    name: string;

    item: ValidationError;
}


