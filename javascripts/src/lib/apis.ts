// License: LGPL-3.0-or-later
import {WebUserSignInOut} from "./api/sign_in";
import {PutDonation} from './api/put_donation';
import {CreateOffsiteDonation} from "./api/create_offsite_donation";
import { CreateSupporter } from "./api/create_supporter";

export const APIS = [WebUserSignInOut, PutDonation, CreateOffsiteDonation, CreateSupporter]