export interface PostNonprofitUser {
    /**
     * Full name
     */
    name: string;

    /**
     * Username
     */
    email: string;

    /**
     * Password
     */
    password: string;

    /**
     * Password confirmation
     */
    password_confirmation: string;

}
export class PostNonprofitUserException implements Error{

    constructor(obj:PostNonprofitUser, message?:string){
            this.item = obj;

    }

    message: string;
    stack: string;
    name: string;

    item: PostNonprofitUser;
}


