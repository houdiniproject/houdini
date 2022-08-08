// License: LGPL-3.0-or-later

// The old UI interface. Just doing so this is easier to migrate
import { Response } from 'superagent';

export interface UI {
	fail: (response: Response) => void;
	start: () => void;
	success: (response: Response) => void;
}
