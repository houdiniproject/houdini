// License: LGPL-3.0-or-later
import * as React from "react";
import { useIntl } from "../../intl";
import { getLocalizedCountries } from "../../../countries";

interface CountryCodeProps {
}


function CountryCode(props:CountryCodeProps) : JSX.Element {
  const intl = useIntl();
  const countries = getLocalizedCountries(intl.locale);

    return (
      
    );
}

export default CountryCode;