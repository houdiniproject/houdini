// License: LGPL-3.0-or-later
import React, {useCallback} from "react";
import { Field, Formik } from "formik";

import { Location } from "./types";
import { LocalizedCountry, Subregion } from "../../../countries";
import type {Schema as YupSchema} from 'yup';
import useYup from '../../../hooks/'
import { noop } from "lodash";

type OnUpdateArgs = {location:Location, isValid:boolean}
type ValidationSchemaArgs = {validCountries?:LocalizedCountry[], validStates?:Subregion[]}

interface LocationSelectorProps {
	enableReinitialize:boolean;
	initialLocation:Location;
	onUpdate:(args:OnUpdateArgs) => void;
	validationSchema:(args:ValidationSchemaArgs) => YupSchema<{city:any, country:any, stateCode:any}, unknown>;
}



function LocationSelector(props:LocationSelectorProps) : JSX.Element {
	const inputValidationSchema = props.validationSchema;
	const yup = useYup();

	const setLatest

	const validationSchema = useCallback(() => {
		if (inputValidationSchema === noop) {
			return () => yup.
		}
		else {
			return inputValidationSchema;
		}
	}, [inputValidationSchema])
	
	
	return <Formik validationSchema>
		
		</Formik>;
}

LocationSelector.defaultProps = {
	enableReinitalize: false,
	initialLocation: {country: "US", stateCode: "", city: ""},
	validationSchema: noop,
}

export default LocationSelector;