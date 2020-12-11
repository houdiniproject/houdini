import * as React from "react";
import { render, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import AnimatedCheckmark from "./AnimatedCheckmark";
import { IntlProvider } from "../intl";
import I18n from '../../i18n';

function Wrapper(props:React.PropsWithChildren<unknown>) {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const translations = I18n.translations['en'] as any;

	return (<IntlProvider messages={translations} locale={'en'}>
		{props.children}
	</IntlProvider>);
}

describe('Animated Checkmark', () => {
	it('check if it renders', async () => {
		expect.hasAssertions();
		const {getByTestId} = render(<Wrapper><AnimatedCheckmark ariaLabel={"ariaLabel"} role={"role"}></AnimatedCheckmark></Wrapper>);
		const checkmark = getByTestId("CheckmarkTest");
		await waitFor(() => {
			expect(checkmark).toBeInTheDocument();
		});
	});
});
// Make sure the correct values are being passed. In ariaLabel and role.