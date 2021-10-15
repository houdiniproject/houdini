// License: LGPL-3.0-or-later

import { UserPresignedIn } from "../api/mocks/users";
import { setupServer } from "msw/node";





export const server = setupServer(...UserPresignedIn);