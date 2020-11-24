

import { Field, Formik } from "formik";
// License: LGPL-3.0-or-later
import * as React from "react";
import { Location } from "./types";


interface LocationSelectorProps {
	enableReinitialize:boolean;
	initialLocation:Location;
	onUpdate:(location:Location) => void;
}


function LocationSelector(props:LocationSelectorProps) : JSX.Element {

	
	
	return <Formik onSubmit()>
		</Formik>;
}

LocationSelector.defaultProps = {
	enableReinitalize: false,
	initialLocation: {country: "US", stateCode: "", city: ""}
}

export default LocationSelector;