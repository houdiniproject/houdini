export type ValidationError = [string, string[]]

export class ValidationErrorException implements Error{

    constructor(obj:ValidationError, message?:string){
            this.item = obj;
    }

    message: string;
    stack: string;
    name: string;

    item: ValidationError;
}


