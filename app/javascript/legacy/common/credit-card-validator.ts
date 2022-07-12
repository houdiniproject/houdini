// License: LGPL-3.0-or-later
// License: LGPL-3.0-or-later

// There was a JS implementation here for some legacy JS code. To simplify,
// we now use a single implementation but reexport here so we match, the
// "interface" expected by code users.

import {luhnCheck} from '../../legacy_react/src/lib/payments/credit_card';

export default luhnCheck;
