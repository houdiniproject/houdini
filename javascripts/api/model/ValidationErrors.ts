import * as models from './models';

/**
 * Register a nonprofit
 */
export interface ValidationErrors {
    /**
     * errors
     */
    errors?: Array<models.ValidationError>;

}
export class ValidationErrorsException implements Error{

    constructor(obj:ValidationErrors, message?:string){
            this.item = obj;

    }

    message: string;
    stack: string;
    name: string;

    item: ValidationErrors;
}


