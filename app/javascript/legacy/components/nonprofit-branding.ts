// License: LGPL-3.0-or-later
import nonprofitBranding from '../../legacy_react/src/lib/nonprofitBranding';
declare const app: {nonprofit: {brand_color:string}};
export default nonprofitBranding(app.nonprofit.brand_color);

